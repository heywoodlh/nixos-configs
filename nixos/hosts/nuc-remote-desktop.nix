{ config, lib, ... }:

{
  heywoodlh.nixos.remote-desktop = {
    enable = true;
    tailscaleIP = "100.74.91.97";
  };

  services.desktopManager.plasma6.enable = false;
  services.displayManager = {
    gdm.enable = true;
    defaultSession = "hyprland";
    autoLogin = {
      enable = true;
      user = config.heywoodlh.defaults.user.name;
    };
  };
  heywoodlh.cosmic = lib.mkForce false;
  heywoodlh.hyprland = true;
  heywoodlh.nixos.kde.enable = false;
  heywoodlh.nixos.sunshine.enable = false;
}
