{ config, pkgs, ... }:

{
  networking.firewall = {
    allowedTCPPorts = [
      5000
    ];
  };
  services.dockerRegistry = {
    enable = true;
    port = 5000;
    listenAddress = "0.0.0.0";
  };
}
