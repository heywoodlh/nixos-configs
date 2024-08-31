{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      25575
    ];
    allowedUDPPorts = [
      8211
      27015
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      palworld = {
        image = "docker.io/thijsvanloef/palworld-server-docker:v0.39";
        autoStart = true;
        ports = [
          "25575:25575"
          "8211:8211/udp"
          "27015:27015/udp"
        ];
        volumes = [
          "/opt/palworld/data:/palworld"
        ];
        environment = {
          RCON_PORT = "25575";
          TZ = "UTC";
          PLAYERS = "16";
          MULTITHREADING = "true";
          SERVER_NAME = "heywood server";
          SERVER_DESCRIPTION = "heywood server";
          ALLOW_CONNECT_PLATFORM = "Steam";
        };
        environmentFiles = [
          /opt/palworld/palworld.env
        ];
      };
    };
  };
}
