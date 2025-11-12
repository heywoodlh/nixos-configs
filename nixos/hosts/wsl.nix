# Config specific to NixOS on WSL
{ config, pkgs, lib, nixos-wsl, ... }:

{
  imports = [
    ../desktop.nix
    nixos-wsl.nixosModules.wsl
  ];

  networking.hostName = "nixos-wsl"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Denver";

  # WSL settings
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
  home-manager.users.heywoodlh = {
    home.file."bin/windows-setup-firefox" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        windows_username="$(cmd.exe /c "echo %USERNAME%")"
        firefox_profile="/mnt/c/Users/$windows_username/AppData/Roaming/Mozilla/Firefox/Profiles"
        ${pkgs.nix}/bin/nix --extra-experimental-features "flakes nix-command" run "github:heywoodlh/nixos-configs?dir=flakes/firefox#firefox-setup" -- "$firefox_profile"
      '';
    };
    programs = {
      tmux.extraConfig = ''
        # https://github.com/microsoft/WSL/issues/5931#issuecomment-1296783606
        set -sg escape-time 50
      '';
    };
  };
}
