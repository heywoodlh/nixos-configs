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
          "3000:3000"
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
        ports = [
          "5432:5432"
        ];
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
