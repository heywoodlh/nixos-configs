{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.lancacheDns;
in
{
  options.heywoodlh.nixos.lancacheDns = {
    enable = mkEnableOption "lancache as the primary resolver";

    server = mkOption {
      type = types.str;
      default = "100.80.187.50";
      description = "Address of the lancache DNS server.";
    };

    ignoreDhcpDns = mkOption {
      default = false;
      description = "Ignore DHCP-provided DNS so the static nameservers stay authoritative.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.extraSetFlags = [ "--accept-dns=false" ];
    # NetworkManager otherwise registers DHCP resolvers ahead of the static entry
    networking.networkmanager.dns = mkIf cfg.ignoreDhcpDns "none";
    # dns=none alone is not enough: NixOS sets rc-manager=resolvconf, so NM still registers them
    networking.networkmanager.settings.main.rc-manager = mkIf cfg.ignoreDhcpDns "unmanaged";
    # Keep the static entry ahead of any stale NetworkManager entry
    networking.resolvconf.extraConfig = mkIf cfg.ignoreDhcpDns "interface_order='static lo lo[0-9]*'";
    # NM stopped registering, but its old resolvconf key lingers until /run resets
    systemd.services.resolvconf-drop-networkmanager = mkIf cfg.ignoreDhcpDns {
      description = "Drop stale NetworkManager DNS entry from resolvconf";
      wantedBy = ["multi-user.target"];
      after = ["NetworkManager.service" "resolvconf.service" "network-local-commands.service"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${config.networking.resolvconf.package}/sbin/resolvconf -d NetworkManager || true
      '';
    };
    # tailscaled's stub stays the fallback when lancache does not answer
    networking.nameservers = [ cfg.server "100.100.100.100" ];
    networking.search = [ "barn-banana.ts.net" ];
    networking.resolvconf.extraOptions = [ "timeout:2" "attempts:1" ];
  };
}
