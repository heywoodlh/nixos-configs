{ config, pkgs, ... }:

let
  system = pkgs.system;
in {
  networking.firewall.allowedTCPPorts = [
    8081
    8181
  ];

  boot.supportedFilesystems = [
    "btrfs"
  ];

  fileSystems."/media/config" = {
    device = "/dev/disk/by-uuid/2fa5a6c4-b938-4853-844d-c85a77ae33e7";
    fsType = "ext4";
    options = [
      "rw"
      "relatime"
      "nofail"
    ];
  };

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
    dataDir = "/media/config/services/plex";
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
    dataDir = "/media/config/services/lidarr";
    user = "media";
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/config/services/radarr";
    user = "media";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
    dataDir = "/media/config/services/sonarr";
    user = "media";
  };

  #services.sabnzbd = {
  #  enable = true;
  #  user = "media";
  #  configFile = "/media/config/services/sabnzbd/config.ini";
  #};

  # https://github.com/NixOS/nixpkgs/issues/360592
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
    "olm-3.2.16"
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      tautulli = {
        image = "docker.io/linuxserver/tautulli:2.14.3";
        autoStart = true;
        volumes = [
          "/media/config/services/tautulli/config:/config"
          "/media/config/services/tautulli/scripts:/scripts"
        ];
        extraOptions = [ "--network=host" ]; # For tailscale/ntfy.sh to work
      };
      openaudible = {
        image = "docker.io/openaudible/openaudible:latest";
        autoStart = true;
        ports = ["3005:3000"];
        environment = {
          PGID = "995";
          PUID = "995";
        };
        volumes = [
          "/media/config/services/openaudible:/config/OpenAudible"
          "/media/config/services/openaudible/desktop:/config/Desktop"
          "/media/home-media/disk2/books:/media/home-media/disk2/books"
        ];
      };
      sabnzbd = {
        image = "docker.io/linuxserver/sabnzbd:latest";
        autoStart = true;
        ports = ["8082:8081"];
        environment = {
          PGID = "995";
          PUID = "995";
        };
        volumes = [
          "/media/config/services/sabnzbd:/config/"
          "/media/home-media:/media/home-media"
        ];
      };
    };
  };
}
