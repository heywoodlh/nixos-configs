{ config, pkgs, home-manager, nur, ... }:

{
  imports = [
    home-manager.darwinModules.home-manager
  ];
  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [
    nur.overlays.default
  ];
  home-manager.useGlobalPkgs = true;
}
