{ config, pkgs, lib, home-manager, hyprland, ... }:

with lib;

let
  cfg = config.heywoodlh.hyprland;
in {
  options.heywoodlh.hyprland = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh hyprland configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    nix.settings = {
      sandbox = true;
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
    };

    # Enable hyprland
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };
    security.pam.services.swaylock.text = "auth include login";
    hardware.brillo.enable = true;
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    # Keyring
    programs.seahorse.enable = true;
    services.gnome.gnome-keyring.enable = true;

    home-manager.users.heywoodlh = {
      imports = [
        hyprland.homeManagerModules.default
      ];

      heywoodlh.home.hyprland.enable = true;

      wayland.windowManager.hyprland = {
        extraConfig = ''
          env = NIXOS_OZONE_WL, 1
        '';
        systemd.enable = false; # Managed with NixOS module
      };
    };
  };
}
