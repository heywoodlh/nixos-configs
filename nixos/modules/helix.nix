{ config, pkgs, lib, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.helix;
  username = config.heywoodlh.defaults.user.name;
  homeDir = config.heywoodlh.defaults.user.homeDir;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.heywoodlh.helix = mkOption {
    default = false;
    description = ''
      Enable heywoodlh Helix configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    environment.systemPackages = [
      myFlakes.packages.${system}.helix
    ];
    home-manager.users.${username}.heywoodlh.home.helix = {
      enable = true;
      ai = true;
      homelab = true;
    };
    home-manager.users.root.heywoodlh.home.helix = {
      enable = true;
      ai = true;
      homelab = true;
    };
  };
}
