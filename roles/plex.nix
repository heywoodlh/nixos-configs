{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    6789
  ];

  users.users.media = {
    group = "media";
    isSystemUser = true;
    uid = 1050;
  };

  fileSystems."/media/services" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
  };

  fileSystems."/media/movies-1" = {
    device = "10.0.50.50:/media/disk1/movies";
    fsType = "nfs";
  };

  fileSystems."/media/tv-1" = {
    device = "10.0.50.50:/media/disk1/tv";
    fsType = "nfs";
  };

  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/plex";
    user = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/radarr";
    user = "media";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/services/sonarr";
    user = "media";
  };

  services.nzbget = {
    enable = true;
    user = "media";
  };
}
