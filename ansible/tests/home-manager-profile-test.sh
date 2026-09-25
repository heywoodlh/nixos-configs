#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
home_manager_tasks=$(<"${repo_root}/ansible/common/home-manager.yml")
flake=$(<"${repo_root}/flake.nix")
dockerfile=$(<"${repo_root}/ansible/Dockerfile")
entrypoint=$(<"${repo_root}/ansible/entrypoint.sh")

[[ "${home_manager_tasks}" == *"Check whether Home Manager profile exists"* ]]
[[ "${home_manager_tasks}" == *"register: home_manager_profile"* ]]
[[ "${home_manager_tasks}" == *"Install Home Manager profile"* ]]
[[ "${home_manager_tasks}" == *"when: not home_manager_profile.stat.exists"* ]]
[[ "${home_manager_tasks}" == *"Update Home Manager profile"* ]]
[[ "${home_manager_tasks}" == *"when: home_manager_profile.stat.exists"* ]]
[[ "${home_manager_tasks}" == *"{{ nixos_configs_root }}#homeConfigurations.{{ home_manager_configuration }}.activationPackage"* ]]
[[ "${home_manager_tasks}" != *"git+https://tangled.org/heywoodlh.io/nixos-configs#homeConfigurations"* ]]
[[ "${flake}" == *'nixos_configs_root=path:${self}'* ]]
[[ "${dockerfile}" == *"COPY . /nixos-configs"* ]]
[[ "${dockerfile}" == *"RUN chmod -R a+rX /nixos-configs"* ]]
[[ "${entrypoint}" == *"nixos_configs_root=path:/nixos-configs"* ]]
