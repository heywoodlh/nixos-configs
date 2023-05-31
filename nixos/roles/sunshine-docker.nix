{ config, pkgs, ... }:

{
  # Allow Sunshine ports
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      47984
      47989
      48010
    ];
    allowedUDPPorts = [
      47998
      47999
      48000
      48002
      48010
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      sunshine = {
        image = "docker.io/heywoodlh/sunshine:latest";
        autoStart = true;
        volumes = [
          "/opt/sunshine/config:/config"
          "/opt/sunshine/steam:/steam"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--gpus=all"
          "--network=host"
          "-h=sunshine-docker"
          "--memory=8g"
        ];
      };
    };
  };
}
