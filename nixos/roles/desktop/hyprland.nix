{ config, pkgs, home-manager, hyprland, ... }:

{
  nix.settings = {
    sandbox = true;
    substituters = [
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  services.greetd = {
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --theme 'border=black;text=white;prompt=white;time=white;action=gray;button=yellow;container=black;input=lightgray' --cmd '${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop'";
      };
    };
  };

  # Enable hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
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
      ../../../home/linux/hyprland.nix
    ];
    wayland.windowManager.hyprland = {
      extraConfig = ''
        env = NIXOS_OZONE_WL, 1
      '';
      systemd.enable = false; # Managed with NixOS module
    };
  };
}
