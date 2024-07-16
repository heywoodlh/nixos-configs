{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8581
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      serge = {
        image = "docker.io/homebridge/homebridge:2024-06-27";
        autoStart = true;
        volumes = [
          "/opt/homebridge:/homebridge"
        ];
        extraOptions = [
          "--network=host"
          "--privileged"
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
          "--cap-add=SYS_ADMIN"
          "--device=/dev/ttyUSB0"
        ];
      };
    };
  };
}
