{pkgs}: let
  nixos-switch = pkgs.writeShellScriptBin "nixos-switch" ''
    limactl shell nixos nix run "github:nix-community/home-manager" -- switch --flake $HOME/opt/nixos-configs#heywoodlh-lima
  '';
  nixos-build = pkgs.writeShellScriptBin "nixos-build" ''
    attic-setup
    limactl shell nixos mkdir -p /home/heywoodlh.guest/.config/attic
    scp -F $HOME/.lima/nixos/ssh.config $HOME/.config/attic/config.toml lima-nixos:/home/heywoodlh.guest/.config/attic/attic.toml
    ${pkgs.lima}/bin/limactl shell nixos nixos-rebuild build --accept-flake-config --flake $HOME/opt/nixos-configs#nixos-desktop
    ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
    ${pkgs.lima}/bin/limactl shell nixos nixos-rebuild build --accept-flake-config --flake $HOME/opt/nixos-configs#nixos-server
    ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
    ${pkgs.lima}/bin/limactl shell nixos nix build --accept-flake-config $HOME/opt/nixos-configs#nixosConfigurations.nixos-m1-mac-mini.config.boot.kernelPackages.kernel
    ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
    ${pkgs.lima}/bin/limactl shell nixos nix build --accept-flake-config $HOME/opt/nixos-configs#nixosConfigurations.nixos-m1-mac-mini.config.hardware.opengl.package
    ${pkgs.lima}/bin/limactl shell nixos nix run "github:nixos/nixpkgs/nixpkgs-unstable#attic-client" -- push nixos ./result
  '';
in [
  nixos-build
  nixos-switch
]
