#!/usr/bin/env bash

set -ex

# Ansible and Home Manager
sudo -u heywoodlh /linux.sh server --ansible --home-manager || exit 1
