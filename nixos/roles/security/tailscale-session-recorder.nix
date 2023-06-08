{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      ts-session-recorder = {
        image = "docker.io/tailscale/tsrecorder:v1.40.1";
        autoStart = true;
        ports = [
          "443:443"
        ];
        volumes = [
          "/opt/tsrecorder/data:/data"
        ];
        environmentFiles = [
          /opt/tsrecorder/environment
        ];
        cmd = [
          "/tsrecorder"
          "--dst=/data/recordings"
          "--statedir=/data/state"
          "--ui"
        ];
      };
    };
  };
}
