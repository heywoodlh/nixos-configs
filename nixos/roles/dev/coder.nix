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
          "/opt/coder/kube:/home/coder/.kube"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=coder"
        ];
        environmentFiles = [
          /opt/coder/environment
        ];
        dependsOn = ["coder-db"];
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
        volumes = [
          "/opt/coder/db:/var/lib/postgresql/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
