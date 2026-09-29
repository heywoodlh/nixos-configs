import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const kubeDir = resolve(import.meta.dirname, "..");
const dashboard = readFileSync(resolve(kubeDir, "templates/scrutiny-proxy.yaml"), "utf8");
const hosts = ["homelab", "nixos-nuc", "nixos-ops", "nixos-gaming", "nixos-gaming-sarah"];

assert.deepEqual(
  [...dashboard.matchAll(/<a href="\/([^/]+)\/">/g)].map(([, host]) => host),
  hosts,
);

for (const host of hosts) {
  assert.match(dashboard, new RegExp(`<a href="/${host}/">`));
  assert.match(dashboard, new RegExp(`@${host} path /${host} /${host}/\\*`));
  assert.match(dashboard, new RegExp(`handle @${host} \\{`));
  assert.match(dashboard, new RegExp(`http://${host}\\.barn-banana\\.ts\\.net:3050`));
}

assert.doesNotMatch(dashboard, /handle \/nixos-gaming\*/);
assert.doesNotMatch(dashboard, /nixos-slc/);
assert.doesNotMatch(dashboard, /nixos-culug/);
assert.match(dashboard, /requests:\n\s+cpu: 10m\n\s+memory: 32Mi/);
assert.match(dashboard, /limits:\n\s+cpu: 100m\n\s+memory: 128Mi/);
