{ config, pkgs, lib, home-manager, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.server;
in {
  options.heywoodlh.server = mkOption {
    default = false;
    description = "Enable heywoodlh server configuration.";
    type = bool;
  };

  config = mkIf cfg {
    heywoodlh.defaults.enable = true;
    heywoodlh.console = true;
    heywoodlh.sshd.enable = true;
    heywoodlh.sshd.duo = true;
    # Enable backup user
    heywoodlh.backup.enable = true;

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

    # Allow heywoodlh to run sudo commands without password
    security.sudo.wheelNeedsPassword = false;

    # Disable wait-online service for Network Manager
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
