{ config, pkgs, ... }:

let
  scrutiny_config = pkgs.writeText "scrutiny.yaml" ''
  version: 1
  web:
    listen:
      port: 8080
      host: 0.0.0.0
    database:
      location: /opt/scrutiny/config/scrutiny.db
    src:
      frontend:
        path: /opt/scrutiny/web
    influxdb:
      host: 0.0.0.0
      port: 8086
      retention_policy: true
  log:
    level: INFO
  notify:
    urls:
      - "ntfy://ntfy.heywoodlh.io/smartd-notifications"
  '';
in {
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
          "${scrutiny_config}:/opt/scrutiny/config/scrutiny.yaml"
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
