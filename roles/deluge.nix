{ config, pkgs, ... }:

{
  services.deluge = {
    enable = true;
    authFile = "/opt/deluge/auth";
    dataDir = "/opt/deluge/data";
    user = "media";
    openFirewall = true;
    web = {
      enable = true;
      openFirewall = true;
    };
  };
}
