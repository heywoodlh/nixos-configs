{ config, pkgs, ... }:

{
  boot.kernelModules = [ "g_ether" ];
  services.dnsmasq = {
    enable = true;
    settings = {

    };
  };

}
