{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    3050
    3051
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      scrutiny = {
        image = "ghcr.io/analogj/scrutiny:v0.7.1-omnibus";
        autoStart = true;
        ports = [
          "3050:8080"
          "3051:8086"
        ];
        volumes = [
          "/opt/scrutiny/config:/opt/scrutiny/config"
          "/opt/scrutiny/influxdb:/opt/scrutiny/influxdb"
          "/run/udev:/run/udev:ro"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--cap-add=SYS_RAWIO"
        ];
      };
    };
  };
}
