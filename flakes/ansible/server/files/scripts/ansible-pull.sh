#!/usr/bin/env bash

# Source nix
[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# Add to path for pipx
export PATH="$HOME/.local/bin:$PATH"

export ansible_dir="/opt/ansible"

if [ -e /usr/bin/ubios-udapi-server ]
then
  export ansible_dir="/data/ansible"
fi

if command -v nix &>/dev/null
then
  nix run "git+https://tangled.org/heywoodlh.io/nixos-configs/$(git ls-remote https://tangled.org/heywoodlh.io/nixos-configs | head -1 | awk '{print $1}')?dir=flakes/ansible#server"
else
  mkdir -p ${ansible_dir}
  [[ -e "${ansible_dir}/install-ansible.sh" ]] || curl -L 'https://tangled.org/heywoodlh.io/nixos-configs/raw/main/flakes/ansible/server/files/scripts/install-ansible.sh' -o ${ansible_dir}/install-ansible.sh
  chmod +x ${ansible_dir}/install-ansible.sh
  command -v ansible &>/dev/null || ${ansible_dir}/install-ansible.sh # install ansible in case it's been removed for some reason
  curl --silent -L https://tangled.org/heywoodlh.io/nixos-configs/raw/main/flakes/ansible/requirements.yml -o ${ansible_dir}/requirements.yml
  ansible-galaxy install -r ${ansible_dir}/requirements.yml
  # Use system-wide python if it exists
  export EXTRA_ARGS=""
  [[ -e /usr/bin/python3 ]] && export EXTRA_ARGS="-e ansible_python_interpreter=/usr/bin/python3"
  ansible-pull -U https://tangled.org/heywoodlh.io/nixos-configs flakes/ansible/server/standalone.yml "${EXTRA_ARGS}"
fi
