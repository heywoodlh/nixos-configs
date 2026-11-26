#!/bin/sh

gh_asset_url() {
  curl -fsSL --retry 3 --connect-timeout 30 "https://api.github.com/repos/$1/releases?per_page=30" \
    | grep -o '"browser_download_url": *"[^"]*"' \
    | cut -d'"' -f4 \
    | grep -E "$2" \
    | head -1
}

remote_size() {
  curl -fsSIL --retry 3 --connect-timeout 30 "$1" \
    | tr -d '\r' \
    | awk 'tolower($1) == "content-length:" { size = $2 } END { print size }'
}

download() {
  part="$2.part"
  curl -fL --no-progress-meter --show-error --retry 5 --retry-delay 15 --connect-timeout 30 \
    --speed-limit 1024 --speed-time 120 -C - -o "${part}" "$1" \
    || { rm -f "${part}"; curl -fL --no-progress-meter --show-error --retry 5 --retry-delay 15 --connect-timeout 30 \
      --speed-limit 1024 --speed-time 120 -o "${part}" "$1"; } \
    || { rm -f "${part}"; return 1; }
  mv -f "${part}" "$2"
}
