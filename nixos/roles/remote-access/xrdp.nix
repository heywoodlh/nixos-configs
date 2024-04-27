{ config, pkgs, lib, ... }:

{
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "${pkgs.gnome.gnome-remote-desktop}/bin/gnome-remote-desktop";
  };
  services.xserver.displayManager.gdm.wayland = lib.mkForce false;
}
