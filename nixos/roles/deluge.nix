{ config, pkgs, ... }:

{

  services.deluge = {
    enable = true;
    authFile = "/opt/deluge/auth";
    dataDir = "/opt/deluge/data";
    user = "media";
    openFirewall = true;
    extraPackages = [
      pkgs.unzip
      pkgs.gnutar
      pkgs.xz
      pkgs.bzip2
    ];
    web = {
      enable = true;
      openFirewall = true;
    };
  };

  # Allow Tor SOCKS proxy
  networking.firewall.allowedTCPPorts = [
    9150
  ];
  # Tor SOCKS proxy
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      tor-socks-proxy = {
        image = "docker.io/peterdavehello/tor-socks-proxy:latest";
        autoStart = true;
        ports = ["9150:9150"];
      };
    };
  };
}
