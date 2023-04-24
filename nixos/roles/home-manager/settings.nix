{ config, pkgs, home-manager, nur, ... }:

{
  imports = [
    home-manager.nixosModule
  ];
  home-manager.useGlobalPkgs = true;

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [ 
    nur.overlay 
  ];
}
