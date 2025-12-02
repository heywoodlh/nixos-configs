{ config, pkgs, lib, home-manager, nixpkgs-stable, ... }:

with lib;

let
  cfg = config.heywoodlh.gnome;
  system = pkgs.stdenv.hostPlatform.system;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  # Overlay that replaces gnome-shell and gnome-session with the stable ones
  # Because extensions are often broken with the latest gnome-shell
  gnome-stable = (final: prev: {
    gnome-shell  = pkgs-stable.gnome-shell;
    gnome-session = pkgs-stable.gnome-session;
  });
in {
  options.heywoodlh.gnome = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh gnome configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      gnome-stable
    ];

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
  };
}
