{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    1200
  ];

  system.activationScripts.mkRssHubNet = ''
    ${pkgs.docker}/bin/docker network create rsshub &2>/dev/null || true
  '';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      rsshub = {
        image = "docker.io/diygod/rsshub:2023-06-16";
        autoStart = true;
        ports = [
          "1200:1200"
        ];
        extraOptions = [
          "--network=rsshub"
        ];
        volumes = [
          "/etc/localtime:/etc/localtime:ro"
        ];
        dependsOn = [
          "rsshub-browserless"
          "rsshub-redis"
        ];
        environment = {
          NODE_ENV = "1";
          CACHE_TYPE = "redis";
          REDIS_URL = "redis://rsshub-redis:6379/";
          PUPPETEER_WS_ENDPOINT = "ws://rsshub-browserless:3000";
        };
        environmentFiles = [
          /opt/rsshub/environment
        ];
      };
      rsshub-browserless = {
        image = "docker.io/browserless/chrome:1.59-puppeteer-1.20.0";
        autoStart = true;
        extraOptions = [
          "--network=rsshub"
        ];
      };
      rsshub-redis = {
        image = "docker.io/redis:7.0.11-alpine3.18";
        autoStart = true;
        extraOptions = [
          "--network=rsshub"
        ];
        volumes = [
          "/opt/rsshub/redis:/data"
        ];
      };
    };
  };
}
