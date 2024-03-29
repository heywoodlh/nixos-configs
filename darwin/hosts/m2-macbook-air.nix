{ config, pkgs, lib, home-manager, nur, myFlakes, mullvad-browser-home-manager, choose-nixpkgs, spicetify, ... }:


let
  hostname = "macbook-air";
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/pkgs.nix
    ../roles/network.nix
    ../roles/yabai.nix
    ../roles/sketchybar.nix
    ../../home/darwin/settings.nix
  ];

  # Define user settings
  users.users.${username} = import ../roles/user.nix {
    inherit config;
    inherit pkgs;
  };

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit myFlakes;
      inherit choose-nixpkgs;
    };
    # Set home-manager configs for username
    users.${username} = { ... }: {
      imports = [
        (mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
        ../../home/darwin.nix
        ../../home/roles/atuin.nix
      ];
      home.packages = with pkgs; [
        moonlight-qt
        spicetify.packages.aarch64-darwin.nord
        virt-manager
        utm
      ];
    };
  };

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
      "microsoft-remote-desktop"
      "signal"
      "vmware-fusion"
      "zoom"
    ];
    masApps = {
      "Screens 5: VNC Remote Desktop" = 1663047912;
    };
  };

  system.stateVersion = 4;
}
