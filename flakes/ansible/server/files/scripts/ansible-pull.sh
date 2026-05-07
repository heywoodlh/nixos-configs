#!/usr/bin/env bash

# Source nix
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Add to path for pipx
export PATH="$HOME/.local/bin:$PATH"

if command -v nix &>/dev/null
then
  nix run "git+https://tangled.org/heywoodlh.io/nixos-configs/$(git ls-remote https://tangled.org/heywoodlh.io/nixos-configs | head -1 | awk '{print $1}')?dir=flakes/ansible#server"
else
  command -v ansible &>/dev/null || /opt/scripts/install-ansible.sh # install ansible in case it's been removed for some reason
  mkdir -p /opt/ansible/
  curl --silent -L https://tangled.org/heywoodlh.io/nixos-configs/raw/main/flakes/ansible/requirements.yml -o /opt/ansible/requirements.yml
  ansible-galaxy install -r /opt/ansible/requirements.yml
  # Use system-wide python if it exists
  export EXTRA_ARGS=""
  [[ -e /usr/bin/python3 ]] && export EXTRA_ARGS="-e ansible_python_interpreter=/usr/bin/python3"
  ansible-pull -U https://tangled.org/heywoodlh.io/nixos-configs flakes/ansible/server/standalone.yml "${EXTRA_ARGS}"
fi
