{ config, pkgs, lib, home-manager, nur, nix-on-droid, ... }:

{
  imports = [
    ../roles/home-manager/linux/no-desktop.nix
  ];

  # Home-manager config
  home-manager.config = ../roles/home-manager/linux.nix;
  # Read Nix-on-Droid changelog before changing this value
  system.stateVersion = "22.11";
}
