#!/usr/bin/env bash

# Ansible installer script in case Ansible gets removed

export PATH="$HOME/.local/bin:$PATH"

ANSIBLE_CORE_SPEC="ansible-core>=2.14,<=2.21.99"

# Debian-specific commands
if [[ -e /etc/debian_version ]]
then
  apt update
  # Install pipx via apt -- otherwise assume older Debian/Ubuntu version
  # Older installs of Debian/Ubuntu do not have pipx available in apt
  if ! apt install -y pipx git curl
  then
    apt install -y python3-pip git curl python3-venv
    pip3 install --user pipx
  fi

  dpkg -r ansible || true
  pipx install --force --include-deps "${ANSIBLE_CORE_SPEC}"
fi

if grep -q 'Arch Linux' /etc/os-release
then
  pacman -Syu --noconfirm --needed python python-pipx git curl
  pipx install --force --include-deps "${ANSIBLE_CORE_SPEC}"
fi

# systemd-started containers do not inherit the pipx PATH
if [[ -x "$HOME/.local/bin/ansible" ]]
then
  for bin in ansible ansible-playbook ansible-galaxy ansible-config ansible-doc
  do
    ln -sf "$HOME/.local/bin/${bin}" "/usr/local/bin/${bin}"
  done
fi
