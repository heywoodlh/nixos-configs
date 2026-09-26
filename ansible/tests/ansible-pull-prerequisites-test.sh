#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
script=$(<"${repo_root}/ansible/server/files/scripts/ansible-pull.sh")

[[ "${script}" == *'grep -q "ID=debian" /etc/os-release || grep -q "ID_LIKE=debian" /etc/os-release'* ]]
[[ "${script}" == *'grep -q "ID=arch" /etc/os-release || grep -q "ID_LIKE=arch" /etc/os-release'* ]]
[[ "${script}" == *'grep -q "ID=alpine" /etc/os-release'* ]]
[[ "${script}" != *"command -v apt"* ]]
[[ "${script}" != *"command -v pacman"* ]]
[[ "${script}" != *"command -v apk"* ]]
[[ "${script}" == *"apt update && apt install -y git curl"* ]]
[[ "${script}" == *"pacman -Sy --noconfirm git curl"* ]]
[[ "${script}" == *"apk update && apk add --no-cache git curl"* ]]
[[ "${script%%ansible-pull -U*}" == *"apt update && apt install -y git curl"* ]]
[[ "${script%%ansible-pull -U*}" == *"pacman -Sy --noconfirm git curl"* ]]
[[ "${script%%ansible-pull -U*}" == *"apk update && apk add --no-cache git curl"* ]]
