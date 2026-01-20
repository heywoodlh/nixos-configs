{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.cloudflared;

in {
  options.heywoodlh.cloudflared = mkOption {
    default = false;
    description = "Enable heywoodlh cloudflared configuration.";
    type = bool;
  };

  config = mkIf cfg {
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        cloudflared = {
          image = "docker.io/erisamoe/cloudflared:2025.11.1";
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
  };
}
