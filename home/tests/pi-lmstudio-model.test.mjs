import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

const rootDir = resolve(import.meta.dirname, "..", "..");
const llm = readFileSync(resolve(rootDir, "home/modules/llm.nix"), "utf8");

assert.match(llm, /id = cfg\.lmstudio\.model\.name;/);
assert.match(llm, /name = cfg\.lmstudio\.model\.alias;/);
assert.match(llm, /"\$\{lmsBin\}" get --yes "\$\{cfg\.lmstudio\.model\.name\}" \|\| true\n\s+"\$\{lmsBin\}" load --yes "\$\{cfg\.lmstudio\.model\.name\}" --identifier "\$\{cfg\.lmstudio\.model\.name\}" \|\| true/);
