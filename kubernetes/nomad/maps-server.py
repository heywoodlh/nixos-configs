#!/usr/bin/env python3
import datetime
import json
import os
import re
import subprocess
import threading
import time
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse

DATA = Path(os.environ.get("DATA_DIR", "/data"))
APP = Path(os.environ.get("APP_DIR", "/app"))
REGIONS = DATA / "regions"
ASSETS = DATA / "assets"
PMTILES = os.environ.get("PMTILES_BIN", str(DATA / "bin" / "pmtiles"))
BUILD_URL = os.environ.get("PROTOMAPS_BUILD_URL", "https://build.protomaps.com")
SOURCE_OVERRIDE = os.environ.get("PMTILES_SOURCE", "")
PORT = int(os.environ.get("PORT", "8082"))
WORLD = "world"
WORLD_MAXZOOM = 5
NAME_RE = re.compile(r"^[a-z0-9][a-z0-9-]{0,63}$")
TYPES = {
    ".html": "text/html; charset=utf-8",
    ".js": "text/javascript; charset=utf-8",
    ".mjs": "text/javascript; charset=utf-8",
    ".css": "text/css; charset=utf-8",
    ".json": "application/json",
    ".png": "image/png",
    ".pbf": "application/x-protobuf",
    ".pmtiles": "application/octet-stream",
}

jobs = {}
jobs_lock = threading.Lock()
extract_lock = threading.Lock()
build_cache = {"url": None, "at": 0.0}
world_wake = threading.Event()


def latest_build():
    if SOURCE_OVERRIDE:
        return SOURCE_OVERRIDE
    if build_cache["url"] and time.time() - build_cache["at"] < 21600:
        return build_cache["url"]
    today = datetime.date.today()
    for back in range(21):
        url = f"{BUILD_URL}/{today - datetime.timedelta(days=back):%Y%m%d}.pmtiles"
        try:
            request = urllib.request.Request(url, method="HEAD", headers={"User-Agent": "nomad-maps/1.0"})
            with urllib.request.urlopen(request, timeout=20) as response:
                if response.status == 200:
                    build_cache.update(url=url, at=time.time())
                    return url
        except urllib.error.URLError:
            continue
    raise RuntimeError("no recent Protomaps planet build found")


def extract_command(source, dest, bbox, maxzoom, dry_run=False):
    command = [PMTILES, "extract", source, str(dest), f"--maxzoom={maxzoom}"]
    if bbox:
        command.append("--bbox=" + ",".join(f"{value:.6f}" for value in bbox))
    if dry_run:
        command.append("--dry-run")
    return command


def run_extract(job):
    with extract_lock:
        job["state"] = "running"
        dest = REGIONS / f"{job['name']}.pmtiles"
        part = REGIONS / f"{job['name']}.pmtiles.part"
        try:
            if not os.access(PMTILES, os.X_OK):
                raise RuntimeError("pmtiles is not installed yet; maps-init is still downloading it")
            source = latest_build()
            result = subprocess.run(
                extract_command(source, part, job["bbox"], job["maxzoom"]),
                capture_output=True,
                text=True,
            )
            job["log"] = (result.stderr or result.stdout).strip().splitlines()[-3:]
            if result.returncode != 0:
                raise RuntimeError("pmtiles extract failed")
            os.replace(part, dest)
            dest.with_suffix(".json").write_text(json.dumps({
                "bbox": job["bbox"],
                "maxzoom": job["maxzoom"],
                "source": source,
                "created": int(time.time()),
            }))
            job["state"] = "done"
        except Exception as error:
            job["state"] = "failed"
            job["error"] = str(error)
            part.unlink(missing_ok=True)
        job["finished"] = int(time.time())


def start_job(name, bbox, maxzoom):
    job = {
        "id": f"{int(time.time() * 1000)}-{name}",
        "name": name,
        "bbox": bbox,
        "maxzoom": maxzoom,
        "state": "queued",
        "started": int(time.time()),
    }
    with jobs_lock:
        jobs[job["id"]] = job
    threading.Thread(target=run_extract, args=(job,), daemon=True).start()
    return job


def ensure_world():
    while True:
        if (REGIONS / f"{WORLD}.pmtiles").exists():
            return
        while not os.access(PMTILES, os.X_OK):
            time.sleep(5)
        job = start_job(WORLD, None, WORLD_MAXZOOM)
        while job["state"] in ("queued", "running"):
            time.sleep(5)
        if job["state"] == "done":
            return
        world_wake.wait(60)
        world_wake.clear()


def list_regions():
    regions = []
    for path in sorted(REGIONS.glob("*.pmtiles")):
        meta = {}
        sidecar = path.with_suffix(".json")
        if sidecar.exists():
            try:
                meta = json.loads(sidecar.read_text())
            except ValueError:
                meta = {}
        regions.append({
            "name": path.stem,
            "size": path.stat().st_size,
            "bbox": meta.get("bbox"),
            "maxzoom": meta.get("maxzoom"),
            "created": meta.get("created"),
        })
    return regions


def parse_request(payload):
    name = str(payload.get("name", "")).strip().lower()
    if not NAME_RE.match(name) or name == WORLD:
        raise ValueError("name must be lowercase letters, digits and dashes")
    bbox = [float(value) for value in payload.get("bbox", [])]
    if len(bbox) != 4:
        raise ValueError("bbox must be [west, south, east, north]")
    west, south, east, north = bbox
    if not (-180 <= west < east <= 180 and -85.06 <= south < north <= 85.06):
        raise ValueError("bbox is out of range")
    maxzoom = int(payload.get("maxzoom", 12))
    if not 1 <= maxzoom <= 15:
        raise ValueError("maxzoom must be between 1 and 15")
    return name, bbox, maxzoom


class Handler(BaseHTTPRequestHandler):
    server_version = "nomad-maps"

    def log_message(self, format, *args):
        print(f"{self.address_string()} {format % args}", flush=True)

    def send_json(self, payload, status=200):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def send_file(self, path):
        size = path.stat().st_size
        start, end, status = 0, size - 1, 200
        requested = self.headers.get("Range")
        if requested:
            match = re.match(r"^bytes=(\d*)-(\d*)$", requested.strip())
            if match:
                first, last = match.groups()
                if first == "" and last != "":
                    start = max(size - int(last), 0)
                elif first != "":
                    start = int(first)
                    end = min(int(last), size - 1) if last else size - 1
                if start > end or start >= size:
                    self.send_response(416)
                    self.send_header("Content-Range", f"bytes */{size}")
                    self.end_headers()
                    return
                status = 206
        self.send_response(status)
        self.send_header("Content-Type", TYPES.get(path.suffix, "application/octet-stream"))
        self.send_header("Accept-Ranges", "bytes")
        self.send_header("Content-Length", str(end - start + 1))
        self.send_header("Cache-Control", "no-cache")
        if status == 206:
            self.send_header("Content-Range", f"bytes {start}-{end}/{size}")
        self.end_headers()
        if self.command == "HEAD":
            return
        with path.open("rb") as handle:
            handle.seek(start)
            remaining = end - start + 1
            while remaining > 0:
                chunk = handle.read(min(65536, remaining))
                if not chunk:
                    break
                self.wfile.write(chunk)
                remaining -= len(chunk)

    def resolve(self, base, relative):
        candidate = (base / unquote(relative)).resolve()
        if candidate.is_file() and candidate.is_relative_to(base.resolve()):
            return candidate
        return None

    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        path = urlparse(self.path).path
        if path in ("/", "/index.html"):
            self.send_file(APP / "maps-index.html")
        elif path == "/api/regions":
            self.send_json(list_regions())
        elif path == "/api/jobs":
            with jobs_lock:
                self.send_json(sorted(jobs.values(), key=lambda job: job["started"], reverse=True)[:20])
        elif path.startswith("/assets/"):
            target = self.resolve(ASSETS, path[len("/assets/"):])
            self.send_file(target) if target else self.send_error(404)
        elif path.startswith("/tiles/") and path.endswith(".pmtiles"):
            target = self.resolve(REGIONS, path[len("/tiles/"):])
            self.send_file(target) if target else self.send_error(404)
        else:
            self.send_error(404)

    def do_POST(self):
        path = urlparse(self.path).path
        try:
            payload = json.loads(self.rfile.read(int(self.headers.get("Content-Length", "0"))) or b"{}")
            if path == "/api/extract":
                name, bbox, maxzoom = parse_request(payload)
                self.send_json(start_job(name, bbox, maxzoom), 202)
            elif path == "/api/estimate":
                _, bbox, maxzoom = parse_request({**payload, "name": "estimate"})
                result = subprocess.run(
                    extract_command(latest_build(), DATA / "estimate.pmtiles", bbox, maxzoom, dry_run=True),
                    capture_output=True,
                    text=True,
                    timeout=300,
                )
                (DATA / "estimate.pmtiles").unlink(missing_ok=True)
                lines = (result.stderr or result.stdout).strip().splitlines()
                self.send_json({"ok": result.returncode == 0, "message": lines[-1] if lines else ""})
            elif path == "/api/world":
                world_wake.set()
                self.send_json({"ok": True}, 202)
            elif path == "/api/delete":
                name = str(payload.get("name", ""))
                if not NAME_RE.match(name) or name == WORLD:
                    raise ValueError("invalid region")
                for suffix in (".pmtiles", ".json"):
                    (REGIONS / f"{name}{suffix}").unlink(missing_ok=True)
                self.send_json({"ok": True})
            else:
                self.send_error(404)
        except (ValueError, TypeError, RuntimeError, subprocess.TimeoutExpired) as error:
            self.send_json({"error": str(error)}, 400)


def main():
    REGIONS.mkdir(parents=True, exist_ok=True)
    for stale in REGIONS.glob("*.part"):
        stale.unlink(missing_ok=True)
    threading.Thread(target=ensure_world, daemon=True).start()
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()


if __name__ == "__main__":
    main()
