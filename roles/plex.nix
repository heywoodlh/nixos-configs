{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    6789
    8181
  ];

  users.users.media = {
    group = "media";
    isSystemUser = true;
    uid = 995;
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

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      tautulli = {
        image = "docker.io/linuxserver/tautulli:2.11.1";
        ports = ["10.50.50.42:8181:8181"];
        volumes = [
          "/media/services/tautulli/config:/config"
          "/media/services/tautulli/scripts:/scripts"
        ];
      };
    };
  };
}
