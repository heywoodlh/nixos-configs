#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ansible=$(<"${repo_root}/.github/workflows/ansible.yml")
bundles=$(<"${repo_root}/.github/workflows/bundles.yml")
nix_builds=$(<"${repo_root}/.github/workflows/nix-builds.yml")
kubernetes=$(<"${repo_root}/.github/workflows/kubernetes-cd.yaml")
sync=$(<"${repo_root}/.github/workflows/sync-tangled.yml")

[[ "${ansible}" == *"types: [opened, synchronize, reopened]"* ]]
[[ "${ansible}" == *"- ansible/**"* ]]
[[ "${ansible}" != *$'\n  push:'* ]]
[[ "${bundles}" == *"- pkgs/**"* ]]
[[ "${bundles}" == *"- home/modules/**"* ]]
[[ "${bundles}" != *"flakes/"* ]]
[[ "${nix_builds}" == *"paths:"* ]]
[[ "${nix_builds}" == *"- 'nixos/**'"* ]]
[[ "${nix_builds}" == *"- 'darwin/**'"* ]]
[[ "${kubernetes}" == *"- kubernetes/**"* ]]
[[ "${kubernetes}" != *"flakes/"* ]]
[[ "${sync}" == *"branches: [main]"* ]]
