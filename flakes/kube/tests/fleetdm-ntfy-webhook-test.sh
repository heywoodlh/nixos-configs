#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)
template=$(<"${repo_root}/flakes/kube/templates/fleetdm.yaml")
flake=$(<"${repo_root}/flakes/kube/flake.nix")

[[ "${template}" == *"name: fleetdm-ntfy-webhook"* ]]
[[ "${template}" == *"app: fleetdm-ntfy-webhook"* ]]
[[ "${template}" == *"image: @ntfy_webhook_image@"* ]]
[[ "${template}" == *"value: \"http://ntfy.default.svc.cluster.local\""* ]]
[[ "${template}" == *"value: \"security-notifications\""* ]]
[[ "${template}" == *"limits:"* ]]
[[ "${template}" == *"requests:"* ]]
[[ "${flake}" == *"ntfy_webhook_image = \"docker.io/heywoodlh/fleetdm-ntfy-webhook@sha256:"* ]]
