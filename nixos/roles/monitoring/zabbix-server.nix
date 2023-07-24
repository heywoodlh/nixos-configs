{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    80
    10051
  ];

  services = {
    zabbixServer = {
      enable = true;
      database.type = "pgsql";
      listen.port = 10051;
      extraPackages = with pkgs; [
        nettools
        nmap
        traceroute
      ];
    };
    zabbixWeb = {
      enable = true;
      database.type = "pgsql";
      server = {
        port = 10051;
        address = "localhost";
      };
      virtualHost = {
        listen = [
          {
            ip = "*";
            port = 80;
          }
        ];
        hostName = "nix-nvidia.tailscale";
        adminAddr = "admin@localhost";
      };
    };
  };
}
