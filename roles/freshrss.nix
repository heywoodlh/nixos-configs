{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8080
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

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      freshrss = {
        image = "docker.io/linuxserver/freshrss:1.21.0";
        ports = ["10.50.50.42:8080:80"];
        volumes = [
          "/media/services/freshrss:/config"
        ];
      };
      user = "media:nogroup";
    };
  }; 
}
