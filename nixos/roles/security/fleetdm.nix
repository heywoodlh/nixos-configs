{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    9080
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      fleet = {
        image = "docker.io/fleetdm/fleet:c62899e";
        autoStart = true;
        ports = [
          "9080:9080"
        ];
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
          "/opt/fleet/certs:/opt/fleet/certs"
        ];
        dependsOn = [
          "fleet-mysql"
          "fleet-redis"
        ];
        extraOptions = [
          "--network=host"
        ];
        cmd = [
          "/usr/bin/fleet"
          "serve"
        ];
        environmentFiles = [
          /opt/fleet/fleet.env
        ];
      };
      fleet-mysql = {
        image = "docker.io/mysql:8.1.0";
        autoStart = true;
        extraOptions = [
          "--network=host"
        ];
        environmentFiles = [
          /opt/fleet/fleet.env
        ];
        volumes = [
          "/opt/fleet/mysql:/var/lib/mysql"
        ];
      };
      fleet-redis = {
        image = "docker.io/redis:7.2.1";
        autoStart = true;
        extraOptions = [
          "--network=host"
        ];
        volumes = [
          "/opt/fleet/redis:/var/lib/redis"
        ];
      };
    };
  };
}
