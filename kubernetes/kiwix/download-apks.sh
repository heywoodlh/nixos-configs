#!/bin/sh
umask 022
sources_file="${APK_SOURCES_FILE:-/config/apks.txt}"
dest_dir="${APK_DEST:-/kiwix/android}"
failed=0

mkdir -p "${dest_dir}"

head_value() {
  curl -fsSIL --retry 3 --connect-timeout 30 "$1" | tr -d '\r' | awk -v key="$2" 'tolower($1) == key ":" { $1 = ""; value = $0 } END { print value }'
}

latest_github_asset() {
  repo="$1"
  pattern="$2"
  release="$(curl -fsSL --retry 3 --connect-timeout 30 "https://api.github.com/repos/${repo}/releases/latest")" || return 1
  tag="$(printf '%s\n' "${release}" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4)"
  asset_url="$(printf '%s\n' "${release}" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep -E "${pattern}" | head -1)"
  [ -n "${tag}" ] && [ -n "${asset_url}" ] || return 1
  printf '%s %s\n' "${tag}" "${asset_url}"
}

while read -r name kind source pattern; do
  case "${name}" in
    "" | "#"*) continue ;;
  esac

  dest="${dest_dir}/${name}"
  stamp="${dest_dir}/.${name}.stamp"
  part="${dest}.part"

  case "${kind}" in
    github)
      if ! found="$(latest_github_asset "${source}" "${pattern}")"; then
        echo "ERROR: no matching release asset for ${source}"
        failed=$((failed + 1))
        continue
      fi
      tag="${found%% *}"
      url="${found#* }"
      version="${tag}"
      ;;
    url)
      url="${source}"
      version="$(head_value "${url}" etag)$(head_value "${url}" last-modified)"
      ;;
    *)
      echo "ERROR: unknown source kind ${kind} for ${name}"
      failed=$((failed + 1))
      continue
      ;;
  esac

  size="$(head_value "${url}" content-length | tr -d ' ')"
  if [ -z "${size}" ]; then
    echo "ERROR: could not determine size of ${url}"
    failed=$((failed + 1))
    continue
  fi

  current="${version} ${size}"
  if [ -f "${dest}" ] && [ "$(cat "${stamp}" 2>/dev/null)" = "${current}" ] && [ "$(wc -c < "${dest}")" = "${size}" ]; then
    echo "Up to date: ${name} (${version})"
    continue
  fi

  echo "Downloading ${name} (${version}, ${size} bytes)"
  rm -f "${part}"
  if curl -fL --no-progress-meter --show-error --retry 5 --retry-delay 15 --connect-timeout 30 --speed-limit 1024 --speed-time 120 -o "${part}" "${url}" \
    && [ "$(wc -c < "${part}")" = "${size}" ]; then
    mv -f "${part}" "${dest}"
    printf '%s\n' "${current}" > "${stamp}"
  else
    rm -f "${part}"
    echo "ERROR: failed to download ${url}"
    failed=$((failed + 1))
  fi
done < "${sources_file}"

if [ "${failed}" -gt 0 ]; then
  echo "${failed} download(s) failed"
  exit 1
fi
echo "All APKs are up to date"
