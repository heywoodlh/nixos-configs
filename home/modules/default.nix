{ config, pkgs, ... }:

{
  imports = [
    ./lima.nix
    ./docker.nix
    ./sway.nix
  ];
}
