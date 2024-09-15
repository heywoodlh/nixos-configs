{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  networking.firewall.allowedTCPPorts = [
    8081
    8181
    3000
  ];

  boot.supportedFilesystems = [
    "btrfs"
  ];

  fileSystems."/media/home-media/disk1" = {
    device = "/dev/disk/by-uuid/8f645e4b-0544-4ce9-8797-7dfe7f85df5a";
    fsType = "btrfs";
    options = [
      "defaults"
      "space_cache=v2"
      "nofail"
    ];
  };

  fileSystems."/media/home-media/disk2" = {
    device = "/dev/disk/by-uuid/7d1d10dd-392d-47ce-b178-bffd2295637e";
    fsType = "btrfs";
    options = [
      "defaults"
      "space_cache=v2"
      "nofail"
    ];
  };

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
    extraPlugins = [
      (builtins.path {
        name = "Audnexus.bundle";
        path = pkgs.fetchFromGitHub {
          owner = "djdembeck";
          repo = "Audnexus.bundle";
          rev = "v1.3.1";
          sha256 = "sha256-HgbPZdKZq3uT44n+4owjPajBbkEENexyPwkFuriiqU4=";
        };
      })
    ];
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
        image = "docker.io/linuxserver/tautulli:2.14.3";
        autoStart = true;
        volumes = [
          "/opt/tautulli/config:/config"
          "/opt/tautulli/scripts:/scripts"
        ];
        extraOptions = [ "--network=host" ]; # For tailscale/ntfy.sh to work
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
