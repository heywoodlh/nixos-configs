{ config, pkgs, nur, home-manager, ... }:

{
  imports = [
    home-manager.darwinModules.home-manager
  ];
  home-manager.useGlobalPkgs = true;

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [ 
    nur.overlay 
  ];
}
