{ config, pkgs, lib, home-manager, hyprland, ... }:

with lib;

let
  cfg = config.heywoodlh.hyprland;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.hyprland = mkOption {
    default = false;
    description = ''
      Enable heywoodlh hyprland configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
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
    hardware.brillo.enable = true;
    environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

    home-manager.users.${username} = {
      heywoodlh.home.hyprland = true;

      wayland.windowManager.hyprland = {
        extraConfig = ''
          env = NIXOS_OZONE_WL, 1
        '';
        systemd.enable = false; # Managed with NixOS module
      };
    };
  };
}
