{ config, pkgs, ... }:

{
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [
    9100
  ];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "cpu_vulnerabilities"
      "processes"
      "systemd"
      "sysctl"
    ];
  };
}
