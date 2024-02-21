# Remember that this is used for GitHub Actions to test builds
{ config, pkgs, lib, home-manager, nur, myFlakes, mullvad-browser-home-manager, ... }:

let
  hostname = "nix-mac-mini";
  username = "heywoodlh";
in {
  imports = [
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
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
    };
    # Set home-manager configs for username
    users.${username} = { ... }: {
      imports = [
        (mullvad-browser-home-manager + /modules/programs/mullvad-browser.nix)
        ../../home/darwin.nix
      ];
    };
  };

  # Extra homebrew packages for this host
  homebrew.brews = [
    "libheif" # mautrix-imessage
    "libolm" # mautrix-imessage
  ];

  # Set hostname
  networking.hostName = "${hostname}";

  system.stateVersion = 4;
}
