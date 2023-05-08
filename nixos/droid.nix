{ config, pkgs, lib, home-manager, nur, nix-on-droid, ... }:

{
  home-manager.config = ../roles/home-manager/linux.nix { inherit config; inherit pkgs; inherit home-manager; inherit lib; };
  # Read Nix-on-Droid changelog before changing this value
  system.stateVersion = "22.11";
}
