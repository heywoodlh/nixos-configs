import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import { gunzipSync } from 'node:zlib';

const root = new URL('..', import.meta.url);
const patch = await readFile(new URL('ttyd.patch', root), 'utf8');
const generated = await readFile(new URL('src/html.h', root), 'utf8');
const compressed = Uint8Array.from(
  [...generated.matchAll(/0x([0-9a-f]{2})/gi)],
  ([, byte]) => Number.parseInt(byte, 16)
);
const html = gunzipSync(compressed).toString();

test('waits for the configured terminal font before fitting and rendering', () => {
  assert.match(patch, /document\.fonts[\s+]*\.load/);
  assert.match(patch, /terminal\.refresh\(0, terminal\.rows - 1\)/);
  assert.match(html, /document\.fonts\.load/);
  assert.match(html, /\.refresh\(0,[a-z]\.rows-1\)/);
});
