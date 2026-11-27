#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
template=$(<"${repo_root}/flakes/kube/templates/fleetdm.yaml")
manifest=$(<"${repo_root}/flakes/kube/manifests/fleetdm.yaml")

for document in "${template}" "${manifest}"; do
  [[ "${document}" == *"name: FLEET_OSQUERY_RESULT_LOG_PLUGIN"* ]]
  [[ "${document}" == *"value: \"webhook\""* ]]
  [[ "${document}" == *"name: FLEET_WEBHOOK_RESULT_URL"* ]]
  [[ "${document}" == *"http://fleetdm-ntfy-webhook.monitoring.svc.cluster.local:8080/webhook"* ]]
done
