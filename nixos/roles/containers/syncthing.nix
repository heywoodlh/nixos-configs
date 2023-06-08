{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      8384
      22000
    ];
    allowedUDPPorts = [
      21027
    ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      syncthing = {
        image = "docker.io/syncthing/syncthing:1.23.5";
        autoStart = true;
        ports = [
          "8384:8384"
          "22000:22000"
          "21027:21027/udp"
        ];
        volumes = [
          "/media/disk2/ct-storage/syncthing:/var/syncthing"
          "/etc/localtime:/etc/localtime:ro"
        ];
      };
    };
  };
}
