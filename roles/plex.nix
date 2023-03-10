{ config, pkgs, ... }:

{
  fileSystems."/media/services/" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
  };

  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/plex";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/radarr";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/sonarr";
  };

  services.nzbget = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/nzbget";
  };
}
