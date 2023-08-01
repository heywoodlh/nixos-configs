# Remember that this is used for GitHub Actions to test builds
{ config, pkgs, lib, home-manager, nur, fish-configs, ... }:

let
  hostname = "nix-mac-mini";
  username = "heywoodlh";
in {
  imports = [
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../../roles/home-manager/darwin/settings.nix
  ];

  # Define user settings
  users.users.${username} = import ../roles/user.nix { inherit config; inherit pkgs; };

  # Home-Manager config
  home-manager = {
    extraSpecialArgs = {
      inherit fish-configs;
    };
    # Set home-manager configs for username
    users.${username} = import ../../roles/home-manager/darwin.nix;
  };

  # Extra homebrew packages for this host
  homebrew.brews = [
    "libheif" # For mautrix-imessage
  ];

  # Set hostname
  networking.hostName = "${hostname}";

  system.stateVersion = 4;
}
