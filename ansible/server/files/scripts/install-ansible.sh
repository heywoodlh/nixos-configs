#!/usr/bin/env bash

# Ansible installer script in case Ansible gets removed

export PATH="$HOME/.local/bin:$PATH"

ANSIBLE_CORE_VERSION="2.21.*"

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
  command -v ansible &>/dev/null || pipx install --include-deps "ansible-core==${ANSIBLE_CORE_VERSION}"
fi

if grep -q 'Arch Linux' /etc/os-release
then
  pacman -Syu --noconfirm --needed python python-pipx git curl
  command -v ansible &>/dev/null || pipx install --include-deps "ansible-core==${ANSIBLE_CORE_VERSION}"
fi

# systemd-started containers do not inherit the pipx PATH
if [[ -x "$HOME/.local/bin/ansible" ]]
then
  for bin in ansible ansible-playbook ansible-galaxy ansible-config ansible-doc
  do
    ln -sf "$HOME/.local/bin/${bin}" "/usr/local/bin/${bin}"
  done
fi
