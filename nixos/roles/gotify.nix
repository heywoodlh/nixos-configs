{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      8082
    ];
  };

  # Remember to run the following command wto initially setup the bridge:
  # docker run -it --rm --name=protonmail-bridge -v /opt/protonmail-bridge/data:/root docker.io/shenxn/protonmail-bridge:${image_tag} init
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gotify-server = {
        image = "docker.io/gotify/server:2.2.4";
        autoStart = true;
        volumes = [
          "/opt/gotify/config/config.yml:/etc/gotify/config.yml"
          "/opt/gotify/data:/app/data"
        ];
        ports = [
          "8082:80"
        ];
      };
    };
  };
}
