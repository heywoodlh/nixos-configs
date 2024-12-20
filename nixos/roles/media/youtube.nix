{ config, pkgs, ... }:

let
  system = pkgs.system;
  resolvConf = pkgs.writeText "resolv.conf" ''
    nameserver 1.1.1.1
    nameserver 1.0.0.1
  '';
in {
  networking.firewall.allowedTCPPorts = [
    6081
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      metube = {
        image = "ghcr.io/alexta69/metube:2024-12-14";
        autoStart = true;
        volumes = [
          "/media/home-media/disk2/videos:/downloads"
          "${resolvConf}:/etc/resolv.conf"
        ];
        ports = [
          "6081:8081"
        ];
        environment = {
          UID = "995";
          GID = "995";
          DEFAULT_THEME = "dark";
        };
      };
    };
  };
}
