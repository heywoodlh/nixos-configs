{ config, pkgs, lib, stdenv, ... }:

{
  imports = [
    ./docker.nix
    ./lima.nix
    ./qutebrowser.nix
    ./sway.nix
    ./applications.nix
    ./linux-autostart.nix
    ./marp.nix
  ];
}
