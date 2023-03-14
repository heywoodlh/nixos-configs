{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8081
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
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
  };

  fileSystems."/media/movies-1" = {
    device = "10.0.50.50:/media/disk1/movies";
    fsType = "nfs";
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
  };

  fileSystems."/media/tv-1" = {
    device = "10.0.50.50:/media/disk1/tv";
    fsType = "nfs";
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
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

  services.sabnzbd = {
    enable = true;
    user = "media"; 
    configFile = "/media/services/sabnzbd/config.ini";
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
