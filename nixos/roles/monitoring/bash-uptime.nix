{ config, pkgs, lib, ... }:

let
  uptime-yaml = pkgs.writeText "uptime.yaml" ''
    ping:
      hosts:
        - 100.107.238.93
        - 100.126.114.23
        - 100.108.106.50
        - 100.67.2.30
        - 100.108.77.60
        - 100.98.176.50
        - 100.112.71.14
        - 100.69.47.86
      options: "-c 1 -W 1"
      silent: "true"
    curl:
      urls:
        - "https://209.213.47.169:32400"
        - "http://100.108.106.50"
        - "http://100.69.47.86"
      options: "-LIk --silent"
      silent: "true"
  '';
  bash-uptime = pkgs.writeShellScriptBin "bash-uptime" ''
    #!/usr/bin/env bash
    DOWN_HOSTS="$(${pkgs.docker-client}/bin/docker run -it -v ${uptime-yaml}:/app/uptime.yaml docker.io/heywoodlh/bash-uptime | grep DOWN)"
    if [[ -n $DOWN_HOSTS ]]
    then
      ${pkgs.curl}/bin/curl -d "$DOWN_HOSTS" http://100.113.9.57:8082/uptime-notifications
    else
      echo "$(date): no hosts or URLs are down"
    fi
  '';
in
{
  virtualisation.oci-containers.backend = "docker";

  systemd.timers."bash-uptime" = {
    wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/5";
        Unit = "bash-uptime.service";
      };
  };

  systemd.services."bash-uptime" = {
    script = ''
      set -eu
      mkdir -p /var/log/bash-uptime
      ${bash-uptime}/bin/bash-uptime | tee -a /var/log/bash-uptime/$(date +%a).log
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
