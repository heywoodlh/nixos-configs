#!/bin/sh
set -eu

library=/data/library.xml
port="${KIWIX_PORT:-8081}"

rebuild() {
  tmp="$(mktemp /data/.library.XXXXXX)"
  rm -f "${tmp}"
  find /zims -name '*.zim' -type f | sort | while read -r zim; do
    kiwix-manage "${tmp}" add "${zim}" > /dev/null 2>&1 || echo "skipping unreadable ${zim}" >&2
  done
  if [ ! -f "${tmp}" ]; then
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<library version="20110515"></library>\n' > "${tmp}"
  fi
  if cmp -s "${tmp}" "${library}" 2> /dev/null; then
    rm -f "${tmp}"
  else
    mv "${tmp}" "${library}"
  fi
}

rebuild

(
  while sleep 600; do
    rebuild || true
  done
) &

exec kiwix-serve --port="${port}" --urlRootLocation=/kiwix --monitorLibrary --library "${library}"
