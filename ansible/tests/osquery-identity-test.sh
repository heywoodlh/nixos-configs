#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
security=$(<"${repo_root}/ansible/server/tasks/linux/security.yml")

[[ "${security}" == *"ORBIT_HOST_IDENTIFIER=uuid"* ]]
[[ "${security}" == *"path: /etc/default/orbit"* ]]
[[ "${security}" == *"name: orbit.service"* ]]
[[ "${security}" == *"when: orbit_host_identifier.changed"* ]]
