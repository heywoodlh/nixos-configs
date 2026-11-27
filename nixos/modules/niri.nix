{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.heywoodlh.niri;
  username = config.heywoodlh.defaults.user.name;
in {
  options.heywoodlh.niri.enable = mkEnableOption "the Niri Wayland compositor";

  config = mkIf cfg.enable {
    programs.niri.enable = true;
    heywoodlh.defaults.keyring = mkDefault true;
    hardware.brillo.enable = true;

    services.upower.enable = true;
    services.tailscale.extraSetFlags = ["--operator=${username}"];

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XCURSOR_THEME = "Adwaita";
      XCURSOR_SIZE = "24";
    };

    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome];
      config.niri.default = ["gnome" "gtk"];
    };

    home-manager.users.${username} = {
      heywoodlh.home.niri.enable = true;
      heywoodlh.home.keyring.autoUnlock = mkDefault true;
      programs.noctalia.settings.lockscreen.fingerprint = config.services.fprintd.enable;
      programs.noctalia.settings.widget.battery.enabled = config.heywoodlh.laptop;
      programs.noctalia.settings.lockscreen_widgets.widget.name = {
        type = "label";
        output = "";
        cx = 960.0;
        cy = 805.0;
        placement_width = 1920.0;
        placement_height = 1080.0;
        box_width = 300.0;
        box_height = 26.0;
        settings = {
          title = config.users.users.${username}.description;
          background = false;
          color = "#ffffff";
          font_family = "Noto Sans";
          shadow = false;
        };
      };
    };
  };
}
