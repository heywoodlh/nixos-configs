{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8008
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      serge = {
        image = "ghcr.io/nsarrazin/serge:latest";
        autoStart = true;
        ports = ["8008:8008"];
        volumes = [
          "/opt/serge/db:/data/db"
          "/opt/serge/weights:/usr/src/app/weights/"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
