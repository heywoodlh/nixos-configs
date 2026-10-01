#!/usr/bin/env bash
set -euo pipefail

actual=$(nix eval --impure --json --expr '
  let
    flake = builtins.getFlake (toString ./.);
    system = flake.packages.x86_64-linux.nixosConfigurations.nixos-blade.extendModules {
      modules = [
        {
          heywoodlh.luks.yubikey = true;
        }
      ];
    };
  in
  system.config.stylix.targets.plymouth.enable
')

if [ "$actual" != false ]; then
  printf 'expected Stylix Plymouth target to be disabled with YubiKey decryption; got %s\n' "$actual" >&2
  exit 1
fi
