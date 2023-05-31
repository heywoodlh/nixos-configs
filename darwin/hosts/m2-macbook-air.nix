{ config, pkgs, lib, home-manager, nur, ... }:


let
  hostname = "nix-macbook-air";
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../../roles/home-manager/darwin/settings.nix
  ];

  # Define user settings
  users.users.${username} = import ../roles/user.nix { inherit config; inherit pkgs; };

  # Set home-manager configs for username
  home-manager.users.${username} = import ../../roles/home-manager/darwin.nix;

  # Set hostname
  networking.hostName = "${hostname}";

  # Always show menu bar on M2 Macbook Air
  system.defaults.NSGlobalDomain._HIHideMenuBar = lib.mkForce false;

  # Applications specific to this machine
  homebrew = {
    casks = [
      "libreoffice"
      "zoom"
    ];
  };

  system.stateVersion = 4;
}
