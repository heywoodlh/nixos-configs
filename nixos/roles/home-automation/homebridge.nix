{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8581
    8081
    1883
    9001
  ];

  system.activationScripts.mkMqttNet = ''
    ${pkgs.docker}/bin/docker network ls | grep -iq mqtt || ${pkgs.docker}/bin/docker network create mqtt
  '';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      homebridge = {
        image = "docker.io/homebridge/homebridge:2024-10-25";
        autoStart = true;
        volumes = [
          "/opt/homebridge:/homebridge"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      zigbee2mqtt = {
        image = "docker.io/koenkk/zigbee2mqtt:1.41.0";
        autoStart = true;
        ports = [
          "8081:8080"
        ];
        volumes = [
          "/opt/zigbee2mqtt:/app/data"
          "/run/udev:/run/udev:ro"
        ];
        environment = {
          TZ = "America/Denver";
        };
        extraOptions = [
          "--privileged"
          "--device=/dev/ttyUSB0"
          "--network=mqtt"
        ];
      };
      mqtt = {
        image = "docker.io/eclipse-mosquitto:2.0.20";
        autoStart = true;
        cmd = [
          "mosquitto"
          "-c"
          "/mosquitto-no-auth.conf"
        ];
        ports = [
          "1883:1883"
          "9001:9001"
        ];
        volumes = [
          "/opt/mqtt:/app/data"
          "/run/udev:/run/udev:ro"
        ];
        environment = {
          TZ = "America/Denver";
        };
        extraOptions = [
          "--network=mqtt"
        ];
      };
    };
  };
}
