{ config, pkgs, lib, home-manager, nur, myFlakes, mullvad-browser-home-manager, choose-nixpkgs, spicetify, ... }:


let
  hostname = "m1-macbook-pro";
in {
  imports = [
    ../roles/base.nix
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/pkgs.nix
    ../roles/network.nix
    ../roles/yabai.nix
    ../roles/sketchybar.nix
    ../../home/darwin/settings.nix
  ];

  # Set hostname
  networking.hostName = "${hostname}";

  # Applications specific to this machine
  homebrew = {
    brews = [
      "neofetch"
    ];
    casks = [
      "diffusionbee"
      "discord"
      "docker"
      "microsoft-remote-desktop"
      "signal"
      "vmware-fusion"
      "zoom"
    ];
    masApps = {
      "Screens 5: VNC Remote Desktop" = 1663047912;
    };
  };
  home-manager.users.heywoodlh.home.packages = with pkgs; [
    moonlight-qt
    spicetify.packages.${system}.nord
  ];

  system.stateVersion = 4;
}
