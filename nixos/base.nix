# Configuration loaded for all NixOS hosts
{ config, pkgs, attic, determinate-nix, nixpkgs-stable, lib, nur, home-manager, iamb-home-manager, browsh, hexstrike-ai, ... }:

let
  system = pkgs.system;
  stdenv = pkgs.stdenv;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  imports = [
    ./roles/virtualization/multiarch.nix
    ./roles/nixos/attic.nix
    determinate-nix.nixosModules.default
    home-manager.nixosModules.home-manager
  ];

  # Allow olm for gomuks until issues are resolved
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  nix = {
    package = pkgs.lib.mkForce determinate-nix.packages.${system}.default;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "heywoodlh"
      ];
      extra-substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Stable, system-wide packages
  environment.systemPackages = with stable-pkgs; let
    nixPkg = determinate-nix.packages.${system}.default;
    nixosRebuildWrapper = pkgs.writeShellScript "nixos-rebuild-wrapper" ''
      [[ -d $HOME/opt/nixos-configs ]] || ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /home/heywoodlh/opt/nixos-configs
      # Wrapper to use the stable nixos-rebuild
      sudo ${nixPkg}/bin/nix run "github:nixos/nixpkgs/nixpkgs-unstable#nixos-rebuild-ng" -- $1 --flake /home/heywoodlh/opt/nixos-configs#$(hostname) ''${@:2}
    '';
    myNixosSwitch = pkgs.writeShellScriptBin "nixos-switch" ''
      ${nixosRebuildWrapper} switch $@
    '';
    myNixosBoot = pkgs.writeShellScriptBin "nixos-boot" ''
      ${nixosRebuildWrapper} boot $@
    '';
    myNixosBuild = pkgs.writeShellScriptBin "nixos-build" ''
      ${nixosRebuildWrapper} build $@
    '';
    myNixosSwitchWithFlakes = pkgs.writeShellScriptBin "nixos-switch-with-flakes" ''
      ${myNixosSwitch}/bin/nixos-switch --override-input myFlakes /home/heywoodlh/opt/flakes $@
    '';
  in [
    gptfdisk
    myNixosSwitch
    myNixosSwitchWithFlakes
    myNixosBoot
    myNixosBuild
    mosh
  ];

  # Enable appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {
      inherit nur;
      inherit determinate-nix;
      inherit attic;
      inherit iamb-home-manager;
      inherit browsh;
      inherit hexstrike-ai;
    };
    users.heywoodlh = { ... }: {
      home.activation.docker-rootless-context = ''
        if ! ${pkgs.docker-client}/bin/docker context ls | grep -iq rootless
        then
          ${pkgs.docker-client}/bin/docker context create rootless --docker "host=unix:///run/user/1000/docker.sock" &> /dev/null || true
          ${pkgs.docker-client}/bin/docker context use rootless
        fi
      '';
    };
  };

  # Enable gnupg agent
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  programs.ssh.extraConfig = let
    altBuilder = if stdenv.isx86_64 then "ubuntu-arm64" else "";
  in ''
    # System-wide SSH config for nix builders
    Host mac-mini intel-mac-vm ${altBuilder}
      IdentityAgent /home/heywoodlh/.ssh/agent.sock
  '';

  i18n.defaultLocale = "en_US.UTF-8";

  # NixOS version
  system.stateVersion = "24.11";
}
