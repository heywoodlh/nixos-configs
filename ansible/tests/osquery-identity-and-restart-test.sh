#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
security=$(<"${repo_root}/ansible/server/tasks/linux/security.yml")
unifi=$(<"${repo_root}/ansible/server/tasks/linux/unifi.yml")

[[ "${security}" == *"ORBIT_HOST_IDENTIFIER=uuid"* ]]
[[ "${security}" == *"path: /etc/default/orbit"* ]]
[[ "${security}" == *"name: orbit.service"* ]]
[[ "${security}" == *"when: orbit_host_identifier.changed"* ]]
[[ "${unifi}" == *"path: /etc/systemd/system/osqueryd.service.d"* ]]
[[ "${unifi}" == *"dest: /etc/systemd/system/osqueryd.service.d/restart.conf"* ]]
[[ "${unifi}" == *"src: systemd/osqueryd-restart.conf"* ]]
[[ "${unifi}" == *"daemon_reload: true"* ]]
[[ "${unifi}" == *"when: osquery_flagfile.changed or osquery_binary.changed or osquery_restart_policy.changed"* ]]

entrypoint=$(<"${repo_root}/ansible/entrypoint.sh")
[[ "${entrypoint}" == *"systemctl show osqueryd.service --property=Restart --value"* ]]

override=$(<"${repo_root}/ansible/server/files/systemd/osqueryd-restart.conf")
[[ "${override}" == *"[Service]"* ]]
[[ "${override}" == *"Restart=always"* ]]
