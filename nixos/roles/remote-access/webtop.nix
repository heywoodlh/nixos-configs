{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    3000
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      webtop = {
        image = "docker.io/linuxserver/webtop:ubuntu-xfce";
        autoStart = true;
        volumes = [
          "webtop-nix:/nix"
          "webtop-home:/home"
          "webtop-config:/config"
          "webtop-usr-local-bin:/usr/local/bin"
          "/var/run/docker.sock:/var/run/docker.sock"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--privileged"
          "--network=host"
        ];
        environmentFiles = [
          "/opt/webtop/environment"
        ];
      };
    };
  };
}
