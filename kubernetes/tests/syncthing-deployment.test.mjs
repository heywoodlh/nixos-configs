import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const kubeDir = resolve(import.meta.dirname, "..");
const template = readFileSync(resolve(kubeDir, "templates/syncthing.yaml"), "utf8");
const manifest = readFileSync(resolve(kubeDir, "manifests/syncthing.yaml"), "utf8");

for (const deployment of [template, manifest]) {
  assert.match(deployment, /spec:\n  replicas: (?:@replicas@|1)\n  strategy:\n    type: Recreate\n  selector:/);
}
