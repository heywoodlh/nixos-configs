{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      cloudflared-tunnel = {
        image = "docker.io/cloudflare/cloudflared:2023.8.2";
        autoStart = true;
        cmd = [
          "tunnel"
          "run"
        ];
        volumes = [
          "/opt/cloudflared-tunnel:/etc/cloudflared"
        ];
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
