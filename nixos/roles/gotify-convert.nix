{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gotify-convert = {
        image = "docker.io/heywoodlh/gotify-convert:0.0.1";
        autoStart = true;
        volumes = [
          "/opt/gotify-convert/ntfy/ntfy.yml:/etc/ntfy/ntfy.yml"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environmentFiles = [
          /opt/gotify-convert/gotify-convert.env
        ];
        environment = {
          HTTP_PROXY="http://100.113.9.57:3128";
          HTTPS_PROXY="http://100.113.9.57:3128";
          NO_PROXY="localhost,nix-ext-net.tailscale,*.pushover.net,pushover.net";
        };
        extraOptions = [
          "--tty"
          "--hostname=gotify-convert"
        ];
      };
    };
  };
}
