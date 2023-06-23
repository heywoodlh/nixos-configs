{ config, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [
    19132
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      bedrock = {
        image = "docker.io/itzg/minecraft-bedrock-server:latest";
        autoStart = true;
        ports = [
          "19132:19132/udp"
        ];
        volumes = [
          "/opt/minecraft-bedrock/data:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--interactive"
        ];
        environment = {
          SERVER_NAME = "Heywood Minecraft Server";
          EULA = "TRUE";
          GAMEMODE = "creative";
          DIFFICULTY = "normal";
          FORCE_GAMEMODE = "false";
          TICK_DISTANCE = "12";
          VIEW_DISTANCE = "64";
          LEVEL_NAME = "Wazzzzup";
          TEXTUREPACK_REQUIRED = "true";
          WHITE_LIST = "true";
          ALLOW_CHEATS = "true";
        };
        environmentFiles = [
          /opt/minecraft-bedrock/environment
        ];
      };
    };
  };
}
