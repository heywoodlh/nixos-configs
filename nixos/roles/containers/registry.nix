{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      5000
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      registry = {
        image = "docker.io/registry:2";
        autoStart = true;
        ports = [
          "5000:5000"
        ];
        volumes = [
          "/opt/registry/data:/var/lib/registry"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
