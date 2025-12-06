{ config, pkgs, lib, home-manager, nixpkgs-stable, ... }:

with lib;

let
  cfg = config.heywoodlh.gnome;
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
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

    ## Bluetooth
    hardware.bluetooth = {
      enable = true;
      settings = {
        # Necessary for Airpods
        General = { ControllerMode = "dual"; } ;
      };
    };

    # Seahorse (Gnome Keyring)
    programs.seahorse.enable = true;

    # Disable wait-online service for Network Manager
    systemd.services.NetworkManager-wait-online.enable = false;

    home-manager.users.${username}.heywoodlh.home.gnome = true;
  };
}
