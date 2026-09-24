#!/usr/bin/env bash

# Ansible installer script in case Ansible gets removed

export PATH="$HOME/.local/bin:$PATH"

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
  command -v ansible &>/dev/null || pipx install --include-deps ansible
fi

if grep -q 'Arch Linux' /etc/os-release
then
  pacman -Sy --noconfirm ansible git curl
fi
