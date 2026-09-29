import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const rootDir = resolve(import.meta.dirname, "..", "..");
const llm = readFileSync(resolve(rootDir, "home/modules/llm.nix"), "utf8");
const defaults = readFileSync(resolve(rootDir, "home/modules/darwin-defaults.nix"), "utf8");
const flake = readFileSync(resolve(rootDir, "flake.nix"), "utf8");

assert.match(llm, /apfel = mkOption \{\n\s+default = false;/);
assert.match(llm, /assertion = !cfg\.apfel \|\| stdenv\.hostPlatform\.isDarwin;/);
assert.match(llm, /launchd\.agents\.apfel = \{/);
assert.match(llm, /enable = cfg\.apfel;/);
assert.match(llm, /apfel-serve = pkgs\.writeShellScript "apfel-serve" ''\n\s+\/usr\/bin\/defaults write com\.apple\.CloudSubscriptionFeatures\.optIn "545129924" -bool "true"\n\s+exec \$\{pkgs\.apfel-llm\}\/bin\/apfel --serve/);
assert.match(llm, /ProgramArguments = \[\n\s+"\$\{apfel-serve\}"/);
assert.match(llm, /"apple-foundation" = \{\n\s+baseUrl = "http:\/\/localhost:11434\/v1";/);
assert.match(llm, /id = "apple-foundationmodel";/);
assert.match(flake, /heywoodlh\.home\.llm\.apfel = true;/);
assert.match(defaults, /lib\.optionalString \(config\.heywoodlh\.home\.llm\.apfel == false\) ''\n\s+# Disable Apple Intelligence/);
assert.match(defaults, /# Disable Apple Intelligence Report\n\s+\/usr\/bin\/defaults -currentHost write com\.apple\.AppleIntelligenceReport "reportDuration" -int 0/);
