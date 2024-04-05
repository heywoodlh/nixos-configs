{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3000 ];
  services.openvscode-server = {
    enable = true;
    port = 3000;
    serverDataDir = "/opt/openvscode-server";
    telemetryLevel = "off";
    user = "heywoodlh";
  };
}
