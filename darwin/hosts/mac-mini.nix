# Remember that this is used for GitHub Actions to test builds
{ config, pkgs, lib, home-manager, nur, ... }:

let
  hostname = "nix-mac-mini";
  username = "heywoodlh";
in {
  imports = [
    ../roles/defaults.nix
    ../roles/brew.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../roles/users/${username}.nix
    ../roles/home-manager/settings.nix
  ];

  # Set home-manager configs for username
  home-manager.users.${username} = import ../roles/home-manager/user.nix;

  # Set hostname
  networking.hostName = "${hostname}";

  system.stateVersion = 4;
}
