#!/usr/bin/env bash

[ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix-collect-garbage --delete-old --delete-older-than 7d
