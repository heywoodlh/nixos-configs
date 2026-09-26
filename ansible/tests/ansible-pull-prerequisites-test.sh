#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
script=$(<"${repo_root}/ansible/server/files/scripts/ansible-pull.sh")

[[ "${script}" == *"apt update && apt install -y git curl"* ]]
[[ "${script}" == *"pacman -Sy --noconfirm git curl"* ]]
[[ "${script}" == *"apk update && apk add --no-cache git curl"* ]]
[[ "${script%%ansible-pull -U*}" == *"apt update && apt install -y git curl"* ]]
[[ "${script%%ansible-pull -U*}" == *"pacman -Sy --noconfirm git curl"* ]]
[[ "${script%%ansible-pull -U*}" == *"apk update && apk add --no-cache git curl"* ]]
