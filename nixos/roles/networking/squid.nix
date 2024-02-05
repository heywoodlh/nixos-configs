{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      3128
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      squid = {
        image = "docker.io/heywoodlh/squid:5.2";
        autoStart = true;
        ports = [
          "3128:3128"
        ];
        volumes = [
          "/opt/squid/config:/etc/squid"
          "/opt/squid/cache:/var/spool/squid"
          "/opt/squid/log:/var/log/squid"
        ];
        extraOptions = [
          "--ulimit"
          "nofile=1024:2048"
        ];
      };
    };
  };
}
