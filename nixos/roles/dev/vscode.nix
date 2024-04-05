{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3000 ];

  services.openvscode-server = {
    enable = true;
    serverDataDir = "/opt/openvscode-server";
    withoutConnectionToken = true;
    telemetryLevel = "off";
    user = "heywoodlh";
    port = 3001;
    host = "127.0.0.1";
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    appendHttpConfig = ''
     # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;

      # This might create errors
      proxy_cookie_path / "/; secure; HttpOnly; SameSite=strict";
    '';
    virtualHosts."nix-nvidia" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 3000;
        }
      ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:3001";
        proxyWebsockets = true;
        basicAuthFile = "/opt/openvscode-server/htpasswd";
      };
    };
  };
}
