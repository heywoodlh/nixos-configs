{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    1514
    1515
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      syslog-ng = {
        image = "lscr.io/linuxserver/syslog-ng:3.30.1";
        autoStart = true;
        ports = [
          "1514:1514"
          "1515:1515"
        ];
        environment = {
          TZ = "America/Denver";
          PUID = "1000";
          PGID = "1000";
        };
        volumes = [
          "/opt/syslog-ng/config/syslog-ng.conf:/config/syslog-ng.conf"
          "/opt/syslog-ng/config/conf.d:/config/conf.d"
          "/opt/syslog-ng/data:/data"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
