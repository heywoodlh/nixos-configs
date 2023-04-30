{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      gotify-convert = {
        image = "docker.io/heywoodlh/gotify-convert:0.0.1";
        autoStart = true;
        volumes = [
          "/opt/gotify-pushover/ntfy/ntfy.yml:/etc/ntfy/ntfy.yml"
          "/etc/localtime:/etc/localtime:ro"
        ];
        environmentFiles = [
          "/opt/gotify-convert/gotify-convert.env"
        ];
      };
    };
  };
}
