{ config, pkgs, ... }:

{
  system.activationScripts.mkTabbyNet = ''
    ${pkgs.docker}/bin/docker network create tabby &2>/dev/null || true
  '';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      tabby = {
        image = "ghcr.io/eugeny/tabby-web:latest";
        autoStart = true;
        ports = ["8182:80"];
        environmentFiles = [
          /opt/tabby/tabby-web-env
        ];
        volumes = [
          "/opt/tabby/distros:/app-dist"
          "/opt/tabby/db:/db"
        ];
        dependsOn = [
          "tabby-connection-gateway"
        ];
        extraOptions = [
          "--network=tabby"
        ];
      };
      tabby-connection-gateway = {
        image = "ghcr.io/eugeny/tabby-connection-gateway:master";
        autoStart = true;
        cmd = [
          "--token-auth"
          "--host"
          "0.0.0.0"
          "--port"
          "9000"
        ];
        environmentFiles = [
          /opt/tabby/tabby-connection-gateway-env
        ];
        extraOptions = [
          "--network=tabby"
        ];
      };
    };
  };
}
