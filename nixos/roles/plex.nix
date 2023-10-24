{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  networking.firewall.allowedTCPPorts = [
    8081
    8181
  ];

  users.users.media = {
    group = "media";
    isSystemUser = true;
    uid = 995;
  };

  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/opt/plex";
    user = "media";
  };

  services.lidarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/opt/lidarr";
    user = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/opt/radarr";
    user = "media";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/opt/sonarr";
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
        autoStart = true;
        ports = ["8181:8181"];
        volumes = [
          "/opt/tautulli/config:/config"
          "/opt/tautulli/scripts:/scripts"
        ];
      };
    };
  };
}
