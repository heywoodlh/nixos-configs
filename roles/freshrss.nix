{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8080
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

  config.virtualisation.oci-containers.containers = {
    freshrss = {
      image = "docker.io/linuxserver/freshrss:1.21.0";
      ports = ["10.50.50.42:8080:80"];
      volumes = [
        "/media/services/freshrss:/config"
      ];
    };
  }; 
}
