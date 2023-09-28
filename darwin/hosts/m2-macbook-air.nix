{ config, pkgs, lib, home-manager, nur, vim-configs, fish-configs, wezterm-configs, ... }:


let
  hostname = "nix-macbook-air";
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/network.nix
    ../roles/yabai.nix
    ../roles/sketchybar.nix
    ../../roles/home-manager/darwin/settings.nix
  ];

  # Define user settings
  users.users.${username} = import ../roles/user.nix {
    inherit config;
    inherit pkgs;
  };

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit fish-configs;
      inherit wezterm-configs;
    };
    # Set home-manager configs for username
    users.${username} = { ... }: {
      imports = [
        ../../roles/home-manager/darwin.nix
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
      "moonlight"
      "screens"
      "signal"
      "steam"
      "vmware-fusion"
      "zoom"
    ];
  };

  system.stateVersion = 4;
}
