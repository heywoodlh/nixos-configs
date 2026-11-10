#!/bin/sh
umask 022
urls_file="${ZIM_URLS_FILE:-/config/zims.txt}"
dest_root="${ZIM_DEST:-/kiwix}"
failed=0

remote_size() {
  curl -fsSIL --retry 3 --connect-timeout 30 "$1" | tr -d '\r' | awk 'tolower($1) == "content-length:" { size = $2 } END { print size }'
}

is_dated_zim() {
  case "$1" in
    [0-9][0-9][0-9][0-9]-[0-9][0-9].zim | [0-9][0-9][0-9][0-9]-[0-9][0-9][a-z].zim) return 0 ;;
    *) return 1 ;;
  esac
}

prune_superseded() {
  dir="$1"
  name="$2"
  stem="${name%_*}"
  for old in "${dir}/${stem}_"*.zim; do
    [ -e "${old}" ] || continue
    [ "${old}" = "${dir}/${name}" ] && continue
    suffix="${old##*/}"
    suffix="${suffix#"${stem}"_}"
    if is_dated_zim "${suffix}"; then
      echo "Removing superseded ${old}"
      rm -f "${old}"
    fi
  done
}

while read -r category url _; do
  case "${category}" in
    "" | "#"*) continue ;;
  esac
  [ -n "${url}" ] || continue

  name="${url##*/}"
  dir="${dest_root}/${category}"
  dest="${dir}/${name}"
  part="${dest}.part"
  mkdir -p "${dir}"

  size="$(remote_size "${url}")"
  if [ -z "${size}" ]; then
    echo "ERROR: could not determine size of ${url}"
    failed=$((failed + 1))
    continue
  fi

  if [ -f "${dest}" ] && [ "$(wc -c < "${dest}")" = "${size}" ]; then
    echo "Up to date: ${category}/${name}"
    prune_superseded "${dir}" "${name}"
    continue
  fi

  if [ -f "${part}" ] && [ "$(wc -c < "${part}")" -gt "${size}" ]; then
    rm -f "${part}"
  fi

  echo "Downloading ${category}/${name} (${size} bytes)"
  if curl -fL --no-progress-meter --show-error --retry 5 --retry-delay 15 --connect-timeout 30 --speed-limit 1024 --speed-time 120 -C - -o "${part}" "${url}" \
    && [ "$(wc -c < "${part}")" = "${size}" ]; then
    mv -f "${part}" "${dest}"
    prune_superseded "${dir}" "${name}"
  else
    echo "ERROR: failed to download ${url}"
    failed=$((failed + 1))
  fi
done < "${urls_file}"

if [ "${failed}" -gt 0 ]; then
  echo "${failed} download(s) failed"
  exit 1
fi
echo "All ZIM files are up to date"
