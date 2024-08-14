{ config, pkgs, ... }:

{
  imports = [
    ./docker.nix
    ./lima.nix
    ./qutebrowser.nix
    ./sway.nix
  ];
}
