{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8080
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      freshrss = {
        image = "docker.io/linuxserver/freshrss:1.21.0";
        ports = ["8080:80"];
        volumes = [
          "/media/services/freshrss:/config"
        ];
      };
    };
  };
}
