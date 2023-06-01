# Configuration for VMWare guests
{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = with pkgs; [
    "xorg.xf86videovmware"
  ];
  virtualisation.vmware.guest.enable = true;
}
