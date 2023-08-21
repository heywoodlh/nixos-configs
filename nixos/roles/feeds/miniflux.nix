{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    2000
  ];

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:2000";
    };
    adminCredentialsFile = "/opt/miniflux/creds.txt";
  };
}
