{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.portmaster;

  # Portmaster filters loopback like any other network, and a client reaching a
  # server over localhost shows up as an *incoming* connection to that server.
  # Any deny-by-default incoming policy therefore breaks local client/server
  # pairs -- adb's daemon on 127.0.0.1:5037 hangs this way. Loopback traffic
  # cannot originate off-host, so allowing it outright costs nothing.
  localhostRules = [
    "+ 127.0.0.0/8"
    "+ ::1/128"
  ];

  # Sunshine listens on a block of ports offset from its configured base port
  # (see the offsets used by services.sunshine.openFirewall). Moonlight clients
  # connect in from the LAN as well as the tailnet, so allow them from any
  # network rather than relying on the tailnet rules below.
  sunshinePort = config.services.sunshine.settings.port;
  sunshineRules =
    map (offset: "+ * TCP/${toString (sunshinePort + offset)}") [ (-5) 0 1 21 ]
    ++ map (offset: "+ * UDP/${toString (sunshinePort + offset)}") [ 9 10 11 13 21 ];

  # Allow incoming connections over tailscale0. Portmaster "Incoming Rules"
  # match by network, not interface, so permit the tailnet ranges (CGNAT
  # IPv4 + Tailscale ULA IPv6) and deny incoming from every other network.
  tailscaleRules = [
    "+ 100.64.0.0/10"
    "+ fd7a:115c:a1e0::/48"
    # Tailscale direct (NAT-traversal) connections arrive as UDP on
    # tailscaled's port (41641 by default, incrementing if taken) from
    # peers' real (non-tailnet) IPs, so they don't match the tailnet CIDRs
    # above. Without this allow rule the "- *" below blocks hole-punching
    # and every peer falls back to a high-latency DERP relay.
    "+ * UDP/41641-41651"
    "- *"
  ];

  # Rules are evaluated in order, so every allow has to come before the
  # tailnet rules' trailing "- *" catch-all.
  incomingRules = localhostRules
    ++ optionals config.heywoodlh.nixos.sunshine.enable sunshineRules
    ++ optionals config.services.tailscale.enable tailscaleRules;

  # "Force Block Incoming Connections" (filter/blockInbound) overrides the
  # incoming rule list, so it must be off for any of the above to take effect.
  incomingRulesNeeded =
    config.services.tailscale.enable || config.heywoodlh.nixos.sunshine.enable;

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
          settings = {
            "dns/nameservers" = cfg.dns;
            # "Force Block Device-Local Connections" is stronger than the rule
            # lists, so it has to be off for the localhost rules to apply.
            "filter/blockLocal" = false;
            # Outgoing rules. Connections matching nothing here fall through to
            # the default action, so this only ever adds an allow.
            "filter/endpoints" = localhostRules;
          };
        }
        cfg.extraConf
      ];
    }

    (mkIf incomingRulesNeeded {
      services.portmaster.settings = {
        "filter/blockInbound" = false;
        "filter/serviceEndpoints" = incomingRules;
      };
    })

    (mkIf config.services.tailscale.enable {
      services.tailscale.extraSetFlags = [ "--accept-dns=false" ];
    })
  ]);
}
