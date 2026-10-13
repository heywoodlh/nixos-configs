import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const kubeDir = resolve(import.meta.dirname, "..");
const template = readFileSync(resolve(kubeDir, "templates/gods-eye-view.yaml"), "utf8");
const flake = readFileSync(resolve(kubeDir, "flake.nix"), "utf8");
const render = readFileSync(resolve(kubeDir, "render.sh"), "utf8");
const applications = readFileSync(resolve(kubeDir, "manifests/apps.yaml"), "utf8");

assert.match(template, /name: gods-eye-view/);
assert.match(template, /tailscale\.com\/hostname: "gods-eye-view"/);
assert.match(template, /name: GEV_ALLOWED_HOSTS\n\s+value: "gods-eye-view"/);
assert.match(template, /tailscale\.com\/tags: "tag:http"/);
assert.match(template, /port: 80/);
assert.match(template, /type: ClusterIP/);
assert.doesNotMatch(template, /istio/i);
assert.doesNotMatch(template, /LoadBalancer/);
assert.match(template, /cpu: 250m/);
assert.match(template, /memory: 1Gi/);
assert.match(template, /cpu: "2"/);
assert.match(template, /memory: 2Gi/);
assert.match(template, /name: logs\n\s+mountPath: \/logs\n\s+readOnly: true/);
assert.match(template, /name: logs\n\s+hostPath:\n\s+path: \/logs\n\s+type: Directory/);
assert.doesNotMatch(template, /mountPath: \/workspace\n\s+readOnly: true/);
assert.match(flake, /"gods-eye-view" = mkKubeDrv "gods-eye-view"/);
assert.match(render, /"gods-eye-view"/);
assert.match(applications, /name: gods-eye-view[\s\S]*include: "gods-eye-view\.yaml"/);
