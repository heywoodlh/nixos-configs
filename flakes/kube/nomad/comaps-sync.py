#!/usr/bin/env python3
import base64
import hashlib
import html
import json
import os
import re
import shutil
import sys
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(os.environ.get("COMAPS_ROOT", "/srv/comaps"))
REPO = os.environ.get("COMAPS_REPO", "comaps/comaps")
API = f"https://codeberg.org/api/v1/repos/{REPO}"
RAW = f"https://codeberg.org/{REPO}/raw/tag"
SERVERS = os.environ.get(
    "COMAPS_SERVERS",
    "https://cdn-fi-1.comaps.app/ https://comaps.firewall-gateway.de/ https://comaps.openstreetmap.fr/ "
    "https://comaps-it1.unfoxo.it/ https://cdn-us-2.comaps.tech/ https://mapgen-fi-1.comaps.app/",
).split()
APK_RE = re.compile(r"^CoMaps-\d+-main-release\.apk$")
HEADERS = {"User-Agent": "nomad-comaps-sync/1.0"}

PACKS = {
    "united-states": {"title": "United States", "states": None},
    "intermountain-west": {
        "title": "Intermountain West",
        "states": ["Arizona", "Colorado", "Idaho", "Montana", "Nevada", "New Mexico", "Utah", "Wyoming"],
    },
    "east-coast": {
        "title": "East Coast",
        "states": [
            "Maine", "New Hampshire", "Massachusetts", "Rhode Island", "Connecticut", "New York", "New Jersey",
            "Delaware", "Maryland", "Virginia", "North Carolina", "South Carolina", "Georgia", "Florida",
        ],
    },
}
BASE_FILES = ["World", "WorldCoasts"]


def request(url, extra=None):
    return urllib.request.urlopen(urllib.request.Request(url, headers={**HEADERS, **(extra or {})}), timeout=60)


def fetch_json(url):
    with request(url) as response:
        return json.load(response)


def latest_release():
    for release in fetch_json(f"{API}/releases?limit=40"):
        for asset in release["assets"]:
            if APK_RE.match(asset["name"]):
                return release["tag_name"], asset
    raise RuntimeError("no CoMaps APK release found")


def flatten(node):
    if "g" in node:
        for child in node["g"]:
            yield from flatten(child)
    else:
        yield node


def pack_files(leaves, pack):
    states = pack["states"]
    selected = []
    for leaf in leaves:
        parts = leaf["id"].split("_")
        if leaf["id"] in BASE_FILES:
            continue
        if parts[0] == "US" and (states is None or parts[1] in states):
            selected.append(leaf)
    return selected


def file_ok(path, size):
    return path.is_file() and path.stat().st_size == size


def download(relative, dest, size, sha1, servers):
    part = dest.with_name(dest.name + ".part")
    quoted = urllib.parse.quote(relative)
    for server in servers:
        url = server.rstrip("/") + "/" + quoted
        for _ in range(2):
            try:
                start = part.stat().st_size if part.exists() else 0
                if start > size:
                    part.unlink()
                    start = 0
                headers = {"Range": f"bytes={start}-"} if start else {}
                with request(url, headers) as response:
                    mode = "ab" if start and response.status == 206 else "wb"
                    with part.open(mode) as handle:
                        shutil.copyfileobj(response, handle, 1 << 20)
                digest = hashlib.sha1()
                with part.open("rb") as handle:
                    for chunk in iter(lambda: handle.read(1 << 20), b""):
                        digest.update(chunk)
                if part.stat().st_size == size and base64.b64encode(digest.digest()).decode() == sha1:
                    os.replace(part, dest)
                    return True
                print(f"checksum mismatch from {url}", flush=True)
                part.unlink(missing_ok=True)
            except (urllib.error.URLError, OSError, TimeoutError) as error:
                print(f"{url}: {error}", flush=True)
    return False


def fetch_apk(asset):
    directory = ROOT / "android"
    directory.mkdir(parents=True, exist_ok=True)
    dest = directory / asset["name"]
    if not file_ok(dest, asset["size"]):
        print(f"Downloading {asset['name']}", flush=True)
        part = dest.with_name(dest.name + ".part")
        try:
            with request(asset["browser_download_url"]) as response, part.open("wb") as handle:
                shutil.copyfileobj(response, handle, 1 << 20)
            if part.stat().st_size != asset["size"]:
                raise OSError("size mismatch")
            os.replace(part, dest)
        except (urllib.error.URLError, OSError, TimeoutError) as error:
            part.unlink(missing_ok=True)
            print(f"ERROR: failed to download {asset['name']}: {error}", flush=True)
            return False
    for old in directory.glob("CoMaps-*-main-release.apk"):
        if old != dest:
            old.unlink()
    return True


def prune(series, version):
    maps = ROOT / "maps"
    if not maps.is_dir():
        return
    for series_dir in maps.iterdir():
        for version_dir in series_dir.iterdir():
            if (series_dir.name, version_dir.name) != (series, version):
                print(f"Removing superseded maps {series_dir.name}/{version_dir.name}", flush=True)
                shutil.rmtree(version_dir)
        if not any(series_dir.iterdir()):
            series_dir.rmdir()


def human(size):
    return f"{size / 1e9:.2f} GB" if size >= 1e9 else f"{size / 1e6:.0f} MB"


def write_index(tag, apk, series, version, leaves):
    by_id = {leaf["id"]: leaf for leaf in leaves}
    base = [by_id[name] for name in BASE_FILES if name in by_id]
    rows = []
    packs_dir = ROOT / "packs"
    packs_dir.mkdir(parents=True, exist_ok=True)
    for name, pack in PACKS.items():
        files = base + pack_files(leaves, pack)
        urls = [f"maps/{series}/{version}/{urllib.parse.quote(leaf['id'])}.mwm" for leaf in files]
        (packs_dir / f"{name}.txt").write_text("\n".join(urls) + "\n")
        total = sum(leaf["s"] for leaf in files)
        rows.append(
            f"<tr><td>{html.escape(pack['title'])}</td><td>{len(files)}</td><td>{human(total)}</td>"
            f"<td><a href=\"packs/{name}.txt\">URL list</a></td></tr>"
        )
    page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CoMaps offline</title>
<style>
  :root {{ color-scheme: dark; --bg: #0b1016; --card: #151d27; --line: #243140; --text: #e6edf3; --muted: #8b9bab; --accent: #4ea1ff; }}
  body {{ margin: 0; background: var(--bg); color: var(--text); font: 15px/1.5 system-ui, sans-serif; }}
  main {{ max-width: 860px; margin: 0 auto; padding: 40px 20px; }}
  a {{ color: var(--accent); }}
  .muted {{ color: var(--muted); }}
  pre, code {{ background: var(--card); border: 1px solid var(--line); border-radius: 6px; }}
  pre {{ padding: 12px 14px; overflow-x: auto; }}
  code {{ padding: 1px 6px; }}
  pre code {{ border: 0; padding: 0; }}
  table {{ border-collapse: collapse; width: 100%; }}
  th, td {{ text-align: left; padding: 8px 10px; border-bottom: 1px solid var(--line); }}
</style>
</head>
<body>
<main>
  <p><a href="/">&larr; Nomad</a> &middot; <a href="/files/">Files</a></p>
  <h1>CoMaps offline</h1>
  <p class="muted">Release {html.escape(tag)}, map data {html.escape(version)} (series {html.escape(series)}). Maps are mirrored from the official CoMaps CDN and only match this app release.</p>
  <h2>Android app</h2>
  <p><a href="android/{urllib.parse.quote(apk['name'])}">{html.escape(apk['name'])}</a> <span class="muted">({human(apk['size'])})</span></p>
  <h2>Maps</h2>
  <table>
    <tr><th>Pack</th><th>Files</th><th>Size</th><th></th></tr>
    {''.join(rows)}
  </table>
  <p class="muted">The Intermountain West and East Coast packs are subsets of the United States mirror, so nothing is stored twice. Each file is also available at <code>maps/{html.escape(series)}/{html.escape(version)}/&lt;name&gt;.mwm</code>.</p>
  <h2>Use the mirror in the Android app</h2>
  <p>Install the APK, then open Settings and set <strong>Custom Map Server</strong> to:</p>
  <pre><code id="server"></code></pre>
  <p class="muted">Then download maps as usual. The app only accepts files that match the checksums bundled with this exact release.</p>
  <h2>Linux</h2>
  <pre><code>flatpak install flathub app.comaps.comaps</code></pre>
  <p class="muted">The Linux app is only distributed through Flathub, so this needs internet access once.</p>
</main>
<script>
document.getElementById('server').textContent = location.origin + '/files/comaps/';
</script>
</body>
</html>
"""
    target = ROOT / "index.html"
    part = target.with_name("index.html.part")
    part.write_text(page)
    os.replace(part, target)


def main():
    tag, asset = latest_release()
    countries = fetch_json(f"{RAW}/{urllib.parse.quote(tag)}/data/countries.txt")
    series = countries["map_series"]
    version = str(countries["v"])
    leaves = list(flatten(countries))
    by_id = {leaf["id"]: leaf for leaf in leaves}

    wanted = {}
    for name in BASE_FILES:
        if name in by_id:
            wanted[name] = by_id[name]
    for pack in PACKS.values():
        for leaf in pack_files(leaves, pack):
            wanted[leaf["id"]] = leaf

    failed = 0 if fetch_apk(asset) else 1
    directory = ROOT / "maps" / series / version
    directory.mkdir(parents=True, exist_ok=True)
    for leaf in wanted.values():
        dest = directory / f"{leaf['id']}.mwm"
        if file_ok(dest, leaf["s"]):
            continue
        print(f"Downloading {leaf['id']} ({human(leaf['s'])})", flush=True)
        relative = f"maps/{series}/{version}/{leaf['id']}.mwm"
        if not download(relative, dest, leaf["s"], leaf["sha1_base64"], SERVERS):
            print(f"ERROR: failed to download {leaf['id']}", flush=True)
            failed += 1

    write_index(tag, asset, series, version, leaves)
    if failed:
        print(f"{failed} download(s) failed", flush=True)
        return 1
    prune(series, version)
    print(f"CoMaps mirror is current: {tag}, maps {series}/{version}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
