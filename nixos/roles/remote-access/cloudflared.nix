{ config, pkgs, ... }:

{
  # Use /opt/cloudflared/init.sh to initially auth:
  #   sudo systemctl stop docker-cloudflared
  #   vim /opt/cloudflared/init.sh
  #   sudo /opt/cloudflared/init.sh
  #   Ctrl+C

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      cloudflared = {
        image = "docker.io/erisamoe/cloudflared:2024.12.1";
        autoStart = true;
        cmd = [
          "tunnel"
          "run"
        ];
        volumes = [
          "/opt/cloudflared/config:/etc/cloudflared"
        ];
        environmentFiles = [
          /opt/cloudflared/env
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
