# Config specific to NixOS on WSL
{ config, pkgs, lib, nixos-wsl, ... }:

{
  imports = [
    ../../desktop.nix
    nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "nix-wsl"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Set version of NixOS to target
  system.stateVersion = "23.05";

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = "heywoodlh";
    startMenuLaunchers = true;
    docker-native.enable = true;
  };

  # WSL-specific packages
  environment.systemPackages = with pkgs; [
    busybox
  ];

  # WSL overrides
  home-manager.users.heywoodlh.programs.vscode.enable = lib.mkForce false;
  home-manager.users.heywoodlh.programs.tmux.extraConfig = ''
    # https://github.com/microsoft/WSL/issues/5931#issuecomment-1296783606
    set -sg escape-time 50
  '';
  home-manager.users.heywoodlh.programs.zsh.envExtra = ''
    # WSL extra config
    clear
  '';
}
