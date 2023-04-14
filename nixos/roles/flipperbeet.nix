{ config, pkgs, lib, ... }:

{
  users.users.flipperbeet806 = {
    isNormalUser = true;
    description = "cutie pie";
    extraGroups = [ "networkmanager" ];
    shell = pkgs.bash;
  };

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.defaultSession = lib.mkForce "xfce";
  };

  services.flatpak.enable = true;
}
