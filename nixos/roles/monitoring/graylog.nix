{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    9000
    514
  ];

  virtualisation.oci-containers = {
    containers = {
      mongodb = {
        image = "docker.io/mongo:6.0.9";
        autoStart = true;
        volumes = [
          "/opt/graylog/mongo:/data/db"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      opensearch = {
        image = "docker.io/opensearchproject/opensearch:2.3.0";
        autoStart = true;
        environment = {
          "discovery.type" = "single-node";
          "network.host" = "127.0.0.1";
          "plugins.security.disabled" = "true";
        };
        volumes = [
          "/opt/graylog/opensearch:/usr/share/opensearch/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
      graylog = {
        image = "docker.io/graylog/graylog:5.1.4";
        autoStart = true;
        environment = {
          GRAYLOG_IS_MASTER = "true";
          GRAYLOG_PASSWORD_SECRET = builtins.readFile /opt/graylog/secret.txt;
          GRAYLOG_ROOT_PASSWORD_SHA2 = builtins.readFile /opt/graylog/pass.txt;
          GRAYLOG_HTTP_EXTERNAL_URI = "http://nix-nvidia.tailscale:9000/";
          GRAYLOG_ELASTICSEARCH_HOSTS = "http://localhost:9200";
          GRAYLOG_MONGODB_URI = "mongodb://localhost:27017/graylog";
        };
        volumes = [
          "/opt/graylog/data:/usr/share/graylog/data/data"
          "/opt/graylog/journal:/usr/share/graylog/data/journal"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
