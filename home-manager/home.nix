{ config, pkgs, home-manager, nur, ... }:

{
  imports = [
    ./roles/dotfiles.nix
  ];

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [ 
    nur.overlay 
  ];

  home.stateVersion = "22.11";

  home.packages = import ../roles/packages.nix { inherit config; inherit pkgs; };
  # Dconf/GNOME settings
  dconf.settings = import ../roles/gnome/dconf.nix { inherit config; inherit pkgs; };
  # Firefox settings
  programs.firefox = import ../roles/firefox/linux.nix { inherit config; inherit pkgs; };

}
