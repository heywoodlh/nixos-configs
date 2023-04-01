{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    8182
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      tabby = {
        image = "ghcr.io/eugeny/tabby-web:latest";
        ports = ["10.50.50.31:8080:80"];
        environmentFiles = {
          /opt/tabby/tabby-web-env
        };
      };
      tabby-db = {
        image = "ghcr.io/mariadb:10.7.1";
        volumes = [
          "/opt/tabby/db:/var/lib/mysql"
        ];
        environmentFiles = {
          /opt/tabby/tabby-db-env
        };
      };
      tabby-connection-gateway = {
        image = "ghcr.io/eugeny/tabby-connection-gateway:master";
        ports = ["10.50.50.31:9000:9000"];
        cmd = "--token-auth --host 0.0.0.0";
        environmentFiles = {
          /opt/tabby/tabby-connection-gateway-env
        };
      };
    };
  };
}
