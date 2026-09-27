#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
playbook=$(<"${repo_root}/ansible/server/tasks/linux/unifi.yml")

[[ "${playbook}" == *"url: http://files.barn-banana.ts.net/fleet/osqueryd-aarch64"* ]]
[[ "${playbook}" == *"dest: /opt/osquery/bin/osqueryd"* ]]
[[ "${playbook}" == *"force: true"* ]]
[[ "${playbook}" == *"register: osquery_binary"* ]]
[[ "${playbook}" == *"when: ansible_architecture in ['aarch64', 'arm64']"* ]]
[[ "${playbook}" == *"when: osquery_flagfile.changed or osquery_binary.changed"* ]]
