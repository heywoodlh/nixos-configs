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
        ports = [
          "3000"
        ];
        volumes = [
          "webtop-nix:/nix"
          "webtop-home:/home"
          "webtop-config:/config"
          "/var/run/docker.sock:/var/run/docker.sock"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--privileged"
        ];
        environmentFiles = [
          "/opt/webtop/environment"
        ];
      };
    };
  };
}
