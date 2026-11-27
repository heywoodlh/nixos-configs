{
  config,
  lib,
  ...
}: {
  imports = [
    ../roles/hardware/printers.nix
  ];

  heywoodlh = {
    workstation = true;
    nixos.portmaster.enable = true;
    nixos.portmaster.dns = [
      "dot://45.90.28.89:853?verify=93c264.dns.nextdns.io&name=NextDNS&blockedif=zeroip"
      "dot://45.90.30.89:853?verify=93c264.dns.nextdns.io&name=NextDNS&blockedif=zeroip"
      "dns://100.100.100.100?name=TailscaleDNS&search=barn-banana.ts.net&search-only"
    ];
  };

  networking.search = lib.mkIf (config.heywoodlh.nixos.portmaster.enable && config.services.tailscale.enable) [
    "barn-banana.ts.net"
  ];
}
