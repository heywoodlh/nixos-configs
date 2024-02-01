{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    2000
  ];

  services.miniflux = {
    enable = true;
    config = {
      LISTEN_ADDR = "0.0.0.0:2000";
      #HTTP_CLIENT_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15";
      HTTP_CLIENT_USER_AGENT = "nixos:miniflux:2.0.51 (by /u/slopshoveler)";
    };
    adminCredentialsFile = "/opt/miniflux/creds.txt";
  };
}
