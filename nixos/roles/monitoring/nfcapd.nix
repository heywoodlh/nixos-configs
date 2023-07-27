{ config, pkgs, ... }:

{
  networking.firewall.allowedUDPPorts = [
    9995
  ];

  environment.systemPackages = with pkgs; [
    nfdump
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      nfcapd = {
        image = "docker.io/heywoodlh/nfcapd:1.6.24";
        autoStart = true;
        ports = [
          "9995:9995/udp"
        ];
        volumes = [
          "/opt/nfcapd/flows:/flows"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
