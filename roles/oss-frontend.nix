{ config, pkgs, ... }:

{
  # Various open source front-ends for specific, proprietary web apps
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      teddit = {
        image = "docker.io/teddit/teddit:2.11.1";
        ports = ["8086:8080"];
        environment = {
          REDIS_HOST = "teddit-redis";
          DOMAIN = "teddit.heywoodlh.io";
        };
        dependsOn = [ "teddit-redis" ];
      };
      teddit-redis = {
        image = "docker.io/redis:6.2.5-alpine";
        ports = ["6379:6379"];
        cmd = [ "redis-server" ];
        environment = {
          REDIS_REPLICATION_MODE = "master";
        };
      };

      cloudtube = {
        image = "docker.io/heywoodlh/cloudtube:2023_02";
        ports = ["10412:10412"];
        environment = {
          INSTANCE_URI = "http://second:3000";
        };
        dependsOn = [ "second" ];
      };
      second = {
        image = "docker.io/heywoodlh/second:2023_02";
      };
    };
  };
}
