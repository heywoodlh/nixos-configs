{ config, pkgs, lib, home-manager, nur, ... }:


let
  username = "heywoodlh";
in {
  imports = [
    ../roles/m1.nix
    ../roles/defaults.nix
    ../roles/pkgs.nix
    ../roles/yabai.nix
    ../roles/network.nix
    ../home/settings.nix
  ];

  # Define user settings
  users.users.${username} = import ../roles/user.nix { inherit config; inherit pkgs; };

  # Set home-manager configs for username
  home-manager.users.${username} = import ../home/user.nix;

  # Set hostname
  #networking.hostName = "${hostname}";

  system.stateVersion = 4;
}
