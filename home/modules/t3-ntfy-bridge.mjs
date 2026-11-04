#!/usr/bin/env node
import {execFile} from "node:child_process";
import {readFile} from "node:fs/promises";
import {homedir} from "node:os";
import {join} from "node:path";
import process from "node:process";

const config = {
  baseUrl: (process.env.T3_NOTIFY_BASE_URL ?? "").replace(/\/+$/, ""),
  ntfyUrl: process.env.T3_NOTIFY_NTFY_URL ?? "",
  t3Bin: process.env.T3_NOTIFY_T3_BIN ?? "t3",
  ntfyToken: process.env.T3_NOTIFY_NTFY_TOKEN ?? "",
  ntfyTokenFile: process.env.T3_NOTIFY_NTFY_TOKEN_FILE ?? "",
  pollMs: Math.max(2, Number(process.env.T3_NOTIFY_POLL_SECONDS ?? 10)) * 1000,
  tokenTtl: process.env.T3_NOTIFY_TOKEN_TTL ?? "30d",
};
const sessionLabel = "t3-ntfy-bridge";
const t3Home = process.env.T3CODE_HOME ?? join(homedir(), ".t3");
const protocolHeader = {"x-t3-orchestration-protocol": "2"};

function log(message) {
  process.stderr.write(`${new Date().toISOString()} ${message}\n`);
}

function run(command, args) {
  return new Promise((resolve, reject) => {
    execFile(command, args, {encoding: "utf8", timeout: 60000}, (error, stdout, stderr) => {
      if (error) {
        reject(new Error(`${command} ${args.join(" ")} failed: ${(stderr || error.message).trim()}`));
        return;
      }
      resolve(stdout);
    });
  });
}

function parseJsonOutput(stdout, command) {
  const text = stdout.trim();
  const start = text.search(/[[{]/);
  const end = Math.max(text.lastIndexOf("}"), text.lastIndexOf("]"));
  if (start === -1 || end < start) throw new Error(`${command} printed no JSON`);
  return JSON.parse(text.slice(start, end + 1));
}

async function revokeStaleSessions() {
  const list = parseJsonOutput(
    await run(config.t3Bin, ["auth", "session", "list", "--json"]),
    "t3 auth session list",
  );
  const rows = Array.isArray(list) ? list : (list.sessions ?? []);
  for (const row of rows) {
    if (row.client?.label !== sessionLabel) continue;
    try {
      await run(config.t3Bin, ["auth", "session", "revoke", row.sessionId]);
      log(`revoked stale session ${row.sessionId}`);
    } catch (error) {
      log(`could not revoke ${row.sessionId}: ${error.message}`);
    }
  }
}

async function issueSession() {
  const issued = parseJsonOutput(
    await run(config.t3Bin, [
      "auth",
      "session",
      "issue",
      "--json",
      "--scope",
      "orchestration:read",
      "--ttl",
      config.tokenTtl,
      "--label",
      sessionLabel,
    ]),
    "t3 auth session issue",
  );
  return {
    token: issued.token,
    sessionId: issued.sessionId,
    expiresAt: Date.parse(issued.expiresAt),
  };
}

async function readEnvironmentId() {
  try {
    return (await readFile(join(t3Home, "userdata", "environment-id"), "utf8")).trim();
  } catch {
    return null;
  }
}

async function resolveNtfyToken() {
  if (config.ntfyToken !== "") return config.ntfyToken;
  if (config.ntfyTokenFile === "") return "";
  try {
    return (await readFile(config.ntfyTokenFile, "utf8")).split("\n")[0].trim();
  } catch (error) {
    log(`cannot read ntfy token file: ${error.message}`);
    return "";
  }
}

let session = null;

async function getSession() {
  if (session === null || (Number.isFinite(session.expiresAt) && session.expiresAt - Date.now() < 3600_000)) {
    session = await issueSession();
    log("issued a scoped orchestration:read session");
  }
  return session;
}

async function fetchSnapshot() {
  for (let attempt = 0; attempt < 2; attempt += 1) {
    const current = await getSession();
    const response = await fetch(`${config.baseUrl}/api/orchestration/shell`, {
      headers: {authorization: `Bearer ${current.token}`, ...protocolHeader},
      signal: AbortSignal.timeout(20000),
    });
    if (response.status === 401) {
      session = null;
      continue;
    }
    if (!response.ok) throw new Error(`shell snapshot failed: ${response.status} ${await response.text()}`);
    return await response.json();
  }
  throw new Error("shell snapshot stayed unauthorized after a token refresh");
}

const terminalRunStatus = (status) =>
  ["completed", "interrupted", "failed", "cancelled", "rolled_back"].includes(status);

function shellRuntime(thread) {
  const holdsCompletion = (thread.pendingBackgroundTasks ?? []).some((task) =>
    ["subagent", "monitor", "background_task"].includes(task.kind),
  );
  const parkAtIdle = holdsCompletion && thread.status !== "failed";
  if (thread.latestRunId === null && thread.activeProviderThreadId === null && !parkAtIdle) return null;
  return {status: parkAtIdle ? "idle" : (thread.activityRunStatus ?? thread.status), lastErrorClass: thread.lastErrorClass ?? null};
}

function isChildRunLive(thread) {
  if (thread.activityRunStatus !== undefined) return thread.activityRunStatus !== null;
  return ["preparing", "starting", "running", "waiting"].includes(thread.status);
}

function subagentRequest(thread) {
  const kind = thread.pendingRuntimeRequest?.kind;
  if (kind === undefined || kind === "auth_refresh") return null;
  if (thread.lineage.relationshipToParent !== "subagent") return null;
  if (thread.creationSource === "provider") return null;
  if (!isChildRunLive(thread)) return null;
  return kind === "user_input" ? "user_input" : "approval";
}

function pendingSubagentRequests(threads) {
  const requests = new Map();
  const byId = new Map(threads.map((thread) => [thread.id, thread]));
  for (const child of threads) {
    const request = subagentRequest(child);
    if (request === null) continue;
    const seen = new Set([child.id]);
    let current = child;
    while (current?.lineage.relationshipToParent === "subagent") {
      const parentId = current.lineage.parentThreadId;
      if (parentId === null || seen.has(parentId)) break;
      seen.add(parentId);
      if (requests.get(parentId) !== "approval") requests.set(parentId, request);
      current = byId.get(parentId);
    }
  }
  return requests;
}

function presentThread(thread, pendingSubagentRequest) {
  const latestRun =
    thread.latestRunId === null
      ? null
      : {
          runId: thread.latestRunId,
          status: thread.status === "idle" ? "completed" : thread.status,
          completedAt:
            thread.latestRunCompletedAt === undefined
              ? thread.status === "idle" || terminalRunStatus(thread.status)
                ? thread.updatedAt
                : null
              : thread.latestRunCompletedAt,
        };
  const runtime = shellRuntime(thread);
  const runtimeIsWorking = ["preparing", "starting", "running"].includes(runtime?.status);
  return {
    latestRun,
    runtime,
    blockedOnThreadWait: thread.blockedOnThreadWait ?? false,
    hasPendingApprovals:
      thread.pendingRuntimeRequest !== null &&
      thread.pendingRuntimeRequest !== undefined &&
      thread.pendingRuntimeRequest.kind !== "user_input" &&
      thread.pendingRuntimeRequest.kind !== "auth_refresh",
    hasPendingUserInput:
      thread.pendingRuntimeRequest?.kind === "user_input" &&
      (thread.pendingRuntimeRequest.blocking !== false || !runtimeIsWorking),
    pendingSubagentRequest,
  };
}

function sidebarStatus(thread) {
  if (thread.hasPendingApprovals || thread.pendingSubagentRequest === "approval") return "approval";
  if (thread.hasPendingUserInput || thread.pendingSubagentRequest === "user_input") return "input";
  if (thread.runtime?.status === "running" && thread.blockedOnThreadWait) return "waiting";
  if (["preparing", "queued", "starting", "running", "waiting"].includes(thread.runtime?.status)) return "working";
  if (thread.runtime?.status === "idle") return "waiting";
  if (thread.runtime?.status === "failed") {
    return thread.runtime.lastErrorClass === "usage_limit" ? "limited" : "failed";
  }
  return "ready";
}

const notificationCopy = {
  completion: {title: "Thread completed", tag: "white_check_mark", priority: 3},
  approval: {title: "Approval needed", tag: "shield", priority: 4},
  input: {title: "Input needed", tag: "speech_balloon", priority: 4},
  limited: {title: "Usage limit reached", tag: "hourglass_flowing_sand", priority: 4},
  failed: {title: "Thread failed", tag: "x", priority: 4},
};

function evaluate(previous, snapshot) {
  const next = new Map();
  const events = [];
  const subagentRequests = pendingSubagentRequests(snapshot.threads ?? []);
  for (const raw of snapshot.threads ?? []) {
    if (raw.lineage.relationshipToParent === "subagent") continue;
    const prior = previous.get(raw.id);
    const thread = presentThread(raw, subagentRequests.get(raw.id) ?? null);
    let status = sidebarStatus(thread);
    if (status === "ready" && thread.latestRun?.status === "failed") status = "failed";
    const attention = ["input", "approval", "failed", "limited"].includes(status)
      ? `${thread.latestRun?.runId ?? ""}:${status}`
      : null;
    const completedAt = Date.parse(thread.latestRun?.completedAt ?? "");
    const completion =
      status === "ready" && thread.latestRun?.status === "completed" && Number.isFinite(completedAt)
        ? completedAt
        : (prior?.completion ?? null);
    const state = {attention, completion};
    next.set(raw.id, state);
    if (!prior || raw.archivedAt !== null) continue;
    const kind =
      attention !== null && attention !== prior.attention
        ? "input"
        : !raw.latestRunStopRequested &&
            completion !== null &&
            (prior.completion === null || completion > prior.completion)
          ? "completion"
          : null;
    if (kind === null) continue;
    const copy =
      kind === "completion"
        ? notificationCopy.completion
        : status === "approval"
          ? notificationCopy.approval
          : status === "limited"
            ? notificationCopy.limited
            : status === "failed"
              ? notificationCopy.failed
              : notificationCopy.input;
    events.push({threadId: raw.id, threadTitle: raw.title, ...copy, next: state});
  }
  return {next, events};
}

async function publish(event, environmentId) {
  const headers = {
    title: event.title,
    priority: String(event.priority),
    tags: event.tag,
  };
  if (environmentId !== null && event.threadId !== "") {
    headers.click = `${config.baseUrl}/${environmentId}/${event.threadId}`;
  }
  if (config.ntfyToken !== "") headers.authorization = `Bearer ${config.ntfyToken}`;
  const response = await fetch(config.ntfyUrl, {
    method: "POST",
    headers,
    body: event.threadTitle,
    signal: AbortSignal.timeout(15000),
  });
  if (!response.ok) throw new Error(`ntfy publish failed: ${response.status} ${await response.text()}`);
}

function assert(condition, message) {
  if (!condition) throw new Error(`self-test failed: ${message}`);
}

function fixture(overrides = {}) {
  return {
    id: "thread-1",
    title: "Fix the thing",
    status: "running",
    latestRunId: "run:1",
    latestRunCompletedAt: null,
    latestRunStopRequested: false,
    activityRunStatus: null,
    activeProviderThreadId: "provider-thread-1",
    blockedOnThreadWait: false,
    pendingRuntimeRequest: null,
    pendingBackgroundTasks: [],
    archivedAt: null,
    creationSource: "web",
    lineage: {parentThreadId: null, relationshipToParent: null},
    lastErrorClass: null,
    ...overrides,
  };
}

function selfTest() {
  const running = fixture();
  let state = new Map();
  let result = evaluate(state, {threads: [running]});
  assert(result.events.length === 0, "first snapshot must seed without notifying");
  state = result.next;

  result = evaluate(state, {
    threads: [fixture({status: "completed", latestRunCompletedAt: "2026-11-04T06:00:00.000Z"})],
  });
  assert(result.events.length === 1 && result.events[0].title === "Thread completed", "completion must notify once");
  state = result.next;
  result = evaluate(state, {
    threads: [fixture({status: "completed", latestRunCompletedAt: "2026-11-04T06:00:00.000Z"})],
  });
  assert(result.events.length === 0, "identical snapshot must not renotify");

  result = evaluate(state, {
    threads: [
      fixture({
        latestRunId: "run:2",
        pendingRuntimeRequest: {kind: "command", blocking: true},
      }),
    ],
  });
  assert(result.events.length === 1 && result.events[0].title === "Approval needed", "approval must notify");
  state = result.next;

  result = evaluate(state, {
    threads: [fixture({latestRunId: "run:2", pendingRuntimeRequest: {kind: "user_input", blocking: true}})],
  });
  assert(result.events.length === 1 && result.events[0].title === "Input needed", "user input must notify");
  state = result.next;

  result = evaluate(state, {
    threads: [fixture({latestRunId: "run:3", status: "failed", lastErrorClass: "usage_limit"})],
  });
  assert(result.events.length === 1 && result.events[0].title === "Usage limit reached", "usage limit must notify");
  state = result.next;

  result = evaluate(state, {threads: [fixture({latestRunId: "run:4", status: "failed"})]});
  assert(result.events.length === 1 && result.events[0].title === "Thread failed", "failure must notify");
  state = result.next;

  result = evaluate(state, {
    threads: [
      fixture({
        latestRunId: "run:5",
        status: "completed",
        latestRunStopRequested: true,
        latestRunCompletedAt: "2026-11-04T07:00:00.000Z",
      }),
    ],
  });
  assert(result.events.length === 0, "a stopped run must not report completion");
  state = result.next;

  result = evaluate(new Map(), {
    threads: [
      fixture({id: "child", lineage: {parentThreadId: "thread-1", relationshipToParent: "subagent"}}),
      fixture({id: "archived", archivedAt: "2026-11-04T07:00:00.000Z"}),
    ],
  });
  assert(result.events.length === 0, "subagent and archived threads must stay silent");

  process.stdout.write("self-test passed\n");
}

async function main() {
  if (process.argv.includes("--self-test")) {
    selfTest();
    return;
  }
  if (config.baseUrl === "") throw new Error("T3_NOTIFY_BASE_URL is required");
  if (config.ntfyUrl === "") throw new Error("T3_NOTIFY_NTFY_URL is required");
  config.ntfyToken = await resolveNtfyToken();

  const environmentId = await readEnvironmentId();
  if (process.argv.includes("--notify-test")) {
    await publish(
      {
        title: "T3 notifications connected",
        threadTitle: "The ntfy bridge can reach this topic.",
        priority: 3,
        tag: "white_check_mark",
        threadId: "",
      },
      null,
    );
    process.stdout.write("notify-test published\n");
    return;
  }
  log(`bridging ${config.baseUrl} to ${config.ntfyUrl}${environmentId === null ? "" : ` (environment ${environmentId})`}`);
  await revokeStaleSessions();

  let state = new Map();
  let seeded = false;
  for (;;) {
    try {
      const snapshot = await fetchSnapshot();
      if (!seeded) {
        state = evaluate(state, snapshot).next;
        seeded = true;
        log(`seeded ${state.size} threads`);
      } else {
        const {next, events} = evaluate(state, snapshot);
        for (const event of events) {
          try {
            await publish(event, environmentId);
            log(`notified ${event.title} for ${event.threadId}`);
          } catch (error) {
            log(`notification failed for ${event.threadId}: ${error.message}`);
            next.set(event.threadId, state.get(event.threadId));
          }
        }
        state = next;
      }
    } catch (error) {
      log(`poll failed: ${error.message}`);
    }
    await new Promise((resolve) => setTimeout(resolve, config.pollMs));
  }
}

for (const signal of ["SIGTERM", "SIGINT"]) {
  process.on(signal, () => {
    if (session !== null) {
      run(config.t3Bin, ["auth", "session", "revoke", session.sessionId]).finally(() => process.exit(0));
      setTimeout(() => process.exit(0), 5000).unref();
      return;
    }
    process.exit(0);
  });
}

main().catch((error) => {
  log(`fatal: ${error.message}`);
  process.exit(1);
});
