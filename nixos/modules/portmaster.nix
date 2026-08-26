{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.portmaster;

in {
  options.heywoodlh.nixos.portmaster = {
    enable = mkOption {
      default = false;
      description = "Enable the Portmaster application firewall.";
      type = bool;
    };
    profilePrefix = mkOption {
      default = "[NixOS] ";
      description = "Prefix added to the display name of every declarative Portmaster profile.";
      type = str;
    };
    dns = mkOption {
      default = [
        "dot://1.1.1.1:853?verify=cloudflare-dns.com&name=Cloudflare&blockedif=zeroip"
        "dot://1.0.0.1:853?verify=cloudflare-dns.com&name=Cloudflare&blockedif=zeroip"
      ];
      example = [ "dot://9.9.9.9:853?verify=dns.quad9.net&name=Quad9&blockedif=empty" ];
      description = ''
        DNS servers to use. If using Tailscale set to something like:
        [
          "dot://1.1.1.1:853?verify=cloudflare-dns.com&name=Cloudflare&blockedif=zeroip"
          "dot://1.0.0.1:853?verify=cloudflare-dns.com&name=Cloudflare&blockedif=zeroip"
          "dns://100.100.100.100?name=TailscaleDNS&search=CHANGEME.ts.net&search-only"
        ]
      '';
      type = listOf str;
    };
    extraConf = mkOption {
      default = {};
      description = "Extra configuration merged into `services.portmaster`.";
      type = attrs;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.portmaster = mkMerge [
        {
          enable = true;
          profilePrefix = cfg.profilePrefix;
          settings."dns/nameservers" = cfg.dns;
        }
        cfg.extraConf
      ];
    }

    (mkIf config.services.tailscale.enable {
      services.tailscale.extraSetFlags = [ "--accept-dns=false" ];
    })
  ]);
}
