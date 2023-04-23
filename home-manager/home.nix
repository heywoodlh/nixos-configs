{ config, pkgs, home-manager, ... }:

{
  imports = [
    ./roles/dotfiles.nix
  ];

  # Import nur
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  home.username = "heywoodlh";
  home.homeDirectory = "/home/heywoodlh";
  home.packages = import ../roles/packages.nix { inherit config; inherit pkgs; };
  # Dconf/GNOME settings
  dconf.settings = import ../roles/gnome/dconf.nix { inherit config; inherit pkgs; };
  # Firefox settings
  programs.firefox = import ../roles/firefox/linux.nix { inherit config; inherit pkgs; };

  home.stateVersion = "22.11";
}
