{ config, pkgs, ... }:

{
  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "gnome-remote-desktop";
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-remote-desktop
  ];
}
