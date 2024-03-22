{ config, pkgs, home-manager, ... }:

{
  imports = [ home-manager.nixosModule ];

  services.xrdp = {
    enable = true;
    openFirewall = true;
    defaultWindowManager = "gnome-remote-desktop";
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-remote-desktop
  ];
}
