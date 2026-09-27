#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
playbook=$(<"${repo_root}/ansible/server/tasks/linux/unifi.yml")

# The package must be restored on each Ubiquiti boot even when the private
# Tailscale file host is unavailable. Enrollment assets may remain conditional.
[[ "${playbook}" == *$'- name: install osquery agent\n  block:'* ]]
[[ "${playbook}" != *$'- name: install osquery agent\n  when:'* ]]
[[ "${playbook}" == *"when: (tailscale_server_check.status | default(0)) == 200"* ]]
[[ "${playbook}" == *"daemon_reload: true"* ]]
[[ "${playbook}" == *"osquery_enrollment_material.results | map(attribute='stat.exists') | min"* ]]
