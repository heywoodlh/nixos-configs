{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    3000
  ];

  system.activationScripts.mkCoderNet = ''
    ${pkgs.docker}/bin/docker network create coder &2>/dev/null || true
  '';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      coder = {
        image = "ghcr.io/coder/coder:v0.24.0";
        autoStart = true;
        ports = [
          "8000-8002:8000-8002"
        ];
        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
          "/etc/localtime:/etc/localtime:ro"
        ];
        dependsOn = ["coder-db"];
        environmentFiles = [
          /opt/coder/environment
        ];
      };
      coder-db = {
        image = "docker.io/postgres:14.2";
        autoStart = true;
        extraOptions = [
          "--network=coder"
        ];
        environmentFiles = [
          /opt/coder/environment
        ];
      };
    };
  };
}
