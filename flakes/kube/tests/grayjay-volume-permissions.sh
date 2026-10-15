#!/usr/bin/env bash
set -euo pipefail

manifest="${1:-$(dirname "$0")/../templates/grayjay.yaml}"
text=$(<"$manifest")

for required in \
  'initContainers:' \
  'name: initialize-data-volume' \
  'command: ["chown", "-R", "1000:1000", "/data"]' \
  'runAsUser: 0' \
  'name: http-datadir'; do
  if [[ "$text" != *"$required"* ]]; then
    printf 'missing Grayjay data-volume initialization: %s\n' "$required" >&2
    exit 1
  fi
done
