import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const kubeDir = resolve(import.meta.dirname, "..");
const render = readFileSync(resolve(kubeDir, "render.sh"), "utf8");
const apps = readFileSync(resolve(kubeDir, "manifests/apps.yaml"), "utf8");

assert.doesNotMatch(render, /"tailscale-mullvad-socks-router"/);
assert.doesNotMatch(apps, /name: tailscale-mullvad-socks-router/);
