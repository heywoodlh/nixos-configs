{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    9000
  ];
  services.graylog = {
    enable = true;
    extraConfig = ''
      http_publish_uri = https://0.0.0.0:9000/
    '';
    plugins = with pkgs.graylogPlugins; [
      aggregates
      dnsresolver
      integrations
      snmp
    ];
  };
}
