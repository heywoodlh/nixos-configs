# nixos-configs layout

- `base`: things shared between nix-darwin and NixOS.
- `darwin`: nix-darwin specific configuration.
  - `darwin/modules`: custom nix-darwin modules.
  - `darwin/roles`: nix configurations that just get imported.
- `nixos`: NixOS specific configuration.
  - `nixos/modules`: custom NixOS modules.
  - `nixos/hosts`: host-specific configurations.
  - `nixos/roles`: nix configurations that get imported.
- `home`: home-manager configuration.
  - `home/modules`: custom home-manager modules.
  - `home/base.nix`: applied to all machines.
  - `home/desktop.nix`: applied to all desktop workstations.
  - `home/darwin.nix`: applied to macOS.
  - `home/linux.nix`: applied to Linux.
  - `home/linux`: more things applied to Linux.
- `flakes/kube`: Kubernetes deployment manifests. See `flakes/kube/AGENTS.md`.

## Building

- NixOS configurations are usually built with a helper script called
  `nixos-switch`, which runs
  `sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname)`.

## Flake inputs

- When adding or updating flake inputs, scan `flake.lock` for duplicate
  inputs with `grep _2 flake.lock` (duplicates show up with a `_2`
  suffix). Add appropriate `follows` (e.g. `inputs.nixpkgs.follows =
  "nixpkgs"`) to deduplicate them.

# Code

Do not add multi-line comments ever. Code that is self-explanatory should not have comments.
