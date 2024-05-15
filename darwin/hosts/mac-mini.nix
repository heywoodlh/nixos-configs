# Remember that this is used for GitHub Actions to test builds
{ config, pkgs, lib, home-manager, nur, myFlakes, mullvad-browser-home-manager, ... }:

let
  hostname = "nix-mac-mini";
in {
  imports = [
    ../roles/base.nix
    ../roles/defaults.nix
    ../roles/pkgs.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../roles/sketchybar.nix
    ../../home/darwin/settings.nix
  ];

  # Set hostname
  networking.hostName = "${hostname}";

  system.stateVersion = 4;
}
