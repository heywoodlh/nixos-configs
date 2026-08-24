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
