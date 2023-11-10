{ config, pkgs, ... }:

let
  teddit = {
    port = "8086";
    image_tag = "latest";
    domain = "teddit.heywoodlh.io";
    redis_image_tag = "6.2.5-alpine";
  };
  cloudtube = {
    port = "10412";
    image_tag = "2023_08";
    second_image_tag = "aug_30_hotfix";
  };
in {
  system.activationScripts.mkTedditNet = ''
    ${pkgs.docker}/bin/docker network create teddit  &2>/dev/null || true
  '';

  system.activationScripts.mkCloudtubeNet = ''
    ${pkgs.docker}/bin/docker network create cloudtube &2>/dev/null || true
  '';
  # Various open source front-ends for specific, proprietary web apps
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      teddit = {
        image = "docker.io/teddit/teddit:${teddit.image_tag}";
        autoStart = true;
        ports = ["${teddit.port}:8080"];
        environment = {
          REDIS_HOST = "teddit-redis";
          DOMAIN = "${teddit.domain}";
        };
        dependsOn = [ "teddit-redis" ];
        extraOptions = [
          "--network=teddit"
        ];
      };
      teddit-redis = {
        image = "docker.io/redis:${teddit.redis_image_tag}";
        autoStart = true;
        cmd = [ "redis-server" ];
        environment = {
          REDIS_REPLICATION_MODE = "master";
        };
        extraOptions = [
          "--network=teddit"
        ];
      };

      cloudtube = {
        image = "docker.io/heywoodlh/cloudtube:${cloudtube.image_tag}";
        autoStart = true;
        ports = ["${cloudtube.port}:10412"];
        environment = {
          INSTANCE_URI = "http://second:3000";
        };
        dependsOn = [ "second" ];
        extraOptions = [
          "--network=cloudtube"
        ];
      };
      second = {
        image = "docker.io/heywoodlh/second:${cloudtube.second_image_tag}";
        autoStart = true;
        extraOptions = [
          "--network=cloudtube"
        ];
      };
    };
  };
}
