{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    8080
  ];

  services.guacamole-server = {
    enable = true;
    userMappingXml = "/opt/guacamole/user-mapping.xml";
  };
  services.guacamole-client = {
    enable = true;
  };
}
