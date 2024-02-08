{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  networking.firewall.allowedTCPPorts = [
    8081
    8181
    3000
  ];

  users.groups.media = {};
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
    configFile = "/opt/sabnzbd/config.ini";
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
      openaudible = {
        image = "docker.io/heywoodlh/openaudible:2024_02";
        autoStart = true;
        ports = ["3000:3000"];
        environment = {
          PGID = "995";
          PUID = "995";
        };
        volumes = [
          "/opt/openaudible:/config/OpenAudible"
          "/media/home-media/disk2/books:/media/home-media/disk2/books"
        ];
      };
    };
  };
}
