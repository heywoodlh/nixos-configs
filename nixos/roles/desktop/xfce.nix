{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nordic
  ];
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
  };
  services.displayManager.defaultSession = lib.mkForce "xfce";

  # remap caps lock to super
  services.xserver.xkb.options = "caps:super";
}
