import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const kubeDir = resolve(import.meta.dirname, "..");
const template = readFileSync(resolve(kubeDir, "templates/hermes-agent.yaml"), "utf8");

assert.match(
  template,
  /kind: Role\nmetadata:\n  name: hermes-agent-logbash-exec\n  namespace: monitoring\nrules:\n- apiGroups: \[""\]\n  resources: \["pods\/exec", "pods\/attach"\]\n  verbs: \["create"\]/,
);
assert.match(
  template,
  /kind: RoleBinding\nmetadata:\n  name: hermes-agent-logbash-exec\n  namespace: monitoring\nsubjects:\n- kind: ServiceAccount\n  name: hermes-agent\n  namespace: @namespace@\nroleRef:\n  kind: Role\n  name: hermes-agent-logbash-exec/,
);
const logbashRole = template.split("name: hermes-agent-logbash-exec")[1].split("\n---")[0];
assert.doesNotMatch(logbashRole, /\*/);
