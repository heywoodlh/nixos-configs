import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const rootDir = resolve(import.meta.dirname, "..", "..");
const llm = readFileSync(resolve(rootDir, "home/modules/llm.nix"), "utf8");
const flake = readFileSync(resolve(rootDir, "flake.nix"), "utf8");

assert.match(llm, /appleFoundation = mkOption \{\n\s+default = false;/);
assert.match(llm, /assertion = !cfg\.appleFoundation \|\| stdenv\.hostPlatform\.isDarwin;/);
assert.match(llm, /launchd\.agents\."apple-foundation" = \{/);
assert.match(llm, /ProgramArguments = \[\n\s+"\$\{pkgs\.apfel-llm\}\/bin\/apfel"/);
assert.match(llm, /"apple-foundation" = \{\n\s+baseUrl = "http:\/\/localhost:11434\/v1";/);
assert.match(llm, /id = "apple-foundationmodel";/);
assert.match(flake, /heywoodlh\.home\.llm\.appleFoundation = true;/);
