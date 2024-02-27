{ config, pkgs, lib, home-manager, nur, myFlakes, mullvad-browser-home-manager, choose-nixpkgs, spicetify, ... }:


let
  hostname = "mac-mini";
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/pkgs.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../roles/sketchybar.nix
    ../../home/darwin/settings.nix
    ../roles/binary-cache.nix
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
        utm
      ];
    };
  };

  # Set hostname
  networking.hostName = "${hostname}";

  # Applications specific to this machine
  homebrew = {
    brews = [
      "libheif"
      "libolm"
    ];
    casks = [
      "screens"
      "signal"
      "vmware-fusion"
      "zoom"
    ];
  };

  system.defaults.alf.globalstate = lib.mkForce 0;
  system.defaults.alf.stealthenabled = lib.mkForce 0;

  system.stateVersion = 4;
}
