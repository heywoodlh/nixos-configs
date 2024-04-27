{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 443 ];
  };

  services.kasmweb = {
    enable = true;
    listenPort = 443;
    listenAddress = "0.0.0.0";
    datastorePath = "/opt/kasmweb";
  };
}
