{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.gnome;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.gnome = mkOption {
    default = false;
    description = ''
      Enable heywoodlh gnome configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    services.desktopManager.gnome.enable = true;
    programs.kdeconnect.package = pkgs.gnomeExtensions.gsconnect;
    home-manager.users.${username}.heywoodlh.home.gnome = true;
  };
}
