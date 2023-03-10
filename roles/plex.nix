{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    6789
  ];

  fileSystems."/media/services" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
  };

  fileSystems."/media/services/movies-1" = {
    device = "10.0.50.50:/media/disk1/movies";
    fsType = "nfs";
  };

  fileSystems."/media/services/tv-1" = {
    device = "10.0.50.50:/media/disk1/tv";
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
  };
}
