{ config, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    3000
  ];
  
  services.coder = {
    enable = true;
    listenAddress = "0.0.0.0:3000";
    accessUrl = "https://coder.heywoodlh.io";
  };
}
