{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8080
  ];

  fileSystems."/media/services" = {
    device = "10.0.50.50:/media/disk2/services/media";
    fsType = "nfs";
    options = [ "rw" "bg" "hard" "rsize=1048576" "wsize=1048576" "tcp" "timeo=600" ];
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
    };
  }; 
}
