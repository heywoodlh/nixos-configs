{ config, pkgs, home-manager, nur, vim-configs, nixpkgs-unstable, nixpkgs-backports, ... }:

let
  system = pkgs.system;
  pkgs-unstable = nixpkgs-unstable.legacyPackages.${system};
  pkgs-backports = nixpkgs-backports.legacyPackages.${system};
in {
  imports = [
    home-manager.nixosModule
    ./roles/remote-access/sshd.nix
    ./roles/security/sshd-monitor.nix
    ./roles/squid-client.nix
    ./roles/tailscale.nix
    ./roles/syslog-ng/client.nix
  ];

  home-manager.useGlobalPkgs = true;

  nixpkgs.overlays = [
    # Import nur as nixpkgs.overlays
    nur.overlay
  ];

  # Allow non-free applications to be installed
  nixpkgs.config.allowUnfree = true;

  # So that `nix search` works
  nix.extraOptions = ''
    extra-experimental-features = nix-command flakes
  '';
  # Automatically optimize store for better storage
  nix.settings = {
    auto-optimise-store = true;
    trusted-users = [
      "heywoodlh"
    ];
    substituters = [
      "http://100.108.77.60:5000" # nix-nvidia
      "https://nix-community.cachix.org"
      "https://cache.nixos.org/"
    ];
    trusted-public-keys = [
      "binarycache.heywoodlh.io:hT9E35rju+9L2CE/SDGUsytJtIZJfqVma7B7cp7Jym4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Packages to install on entire system
  environment.systemPackages = [
    pkgs.ansible
    pkgs.autoPatchelfHook
    pkgs.bind
    pkgs.btrfs-progs
    pkgs.busybox
    pkgs.croc
    pkgs.file
    pkgs.gcc
    pkgs.git
    pkgs.gnumake
    pkgs.gnupg
    pkgs.gptfdisk
    pkgs.htop
    pkgs.jq
    pkgs.lsof
    pkgs.nix-index
    pkgs.patchelf
    pkgs.python310
    pkgs.python310Packages.pip
    pkgs.unzip
    vim-configs.defaultPackage.${system}
    pkgs.wireguard-tools
    pkgs.zsh
  ];

  # Enable Docker
  virtualisation = {
    docker = {
      enable = true;
      package = pkgs-backports.docker;
    };
    docker.rootless = {
      package = pkgs-backports.docker;
      enable = true;
      setSocketVariable = true;
    };
  };

  # Define use
  programs.zsh.enable = true;
  users.users.heywoodlh = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/heywoodlh";
    description = "Spencer Heywood";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
  };

  # Set home-manager configs for username
  home-manager.users.heywoodlh = { ... }: {
    imports = [
      ../roles/home-manager/linux.nix
      ../roles/home-manager/linux/no-desktop.nix
    ];
    home.file."bin/nixos-switch" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        [[ -d ~/opt/nixos-configs ]] || git clone https://github.com/heywoodlh/nixos-configs
        git -C ~/opt/nixos-configs pull origin master
        /run/wrappers/bin/sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure $@
      '';
    };
  };

  # Allow heywoodlh to run sudo commands without password
  security.sudo.wheelNeedsPassword = false;

  # Disable wait-online service for Network Manager
  systemd.services.NetworkManager-wait-online.enable = false;

  # Enable cloudflared
  services.cloudflared.enable = true;

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
}
