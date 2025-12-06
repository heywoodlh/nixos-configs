{ config, pkgs, lib, home-manager, nixpkgs-stable, nixpkgs-backports, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.server;
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  pkgs-backports = nixpkgs-backports.legacyPackages.${system};
in {
  options.heywoodlh.server = mkOption {
    default = false;
    type = bool;
  };

  config = let
    username = config.heywoodlh.defaults.user.name;
    userDesc = config.heywoodlh.defaults.user.description;
    userUid = config.heywoodlh.defaults.user.uid;
    homeDir = config.heywoodlh.defaults.user.homeDir;
  in mkIf cfg {
    heywoodlh.defaults.enable = true;

    environment.systemPackages = [
      pkgs.ansible
      pkgs.autoPatchelfHook
      pkgs.bind
      pkgs.btrfs-progs
      pkgs.busybox
      pkgs.croc
      pkgs.file
      pkgs.gcc
      pkgs.gnumake
      pkgs.gnupg
      pkgs.gptfdisk
      pkgs.htop
      pkgs.jq
      pkgs.lsof
      pkgs.patchelf
      pkgs.python3
      pkgs.unzip
      pkgs.wireguard-tools
      pkgs.zsh
    ];

    virtualisation.docker = {
      enable = true;
      package = pkgs-backports.docker;
    };

    # Allow heywoodlh to run sudo commands without password
    security.sudo.wheelNeedsPassword = false;

    # Disable wait-online service for Network Manager
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
