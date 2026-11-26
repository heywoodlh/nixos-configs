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
    # tailscaled's stub stays the fallback when lancache does not answer
    networking.nameservers = [ cfg.server "100.100.100.100" ];
    networking.search = [ "barn-banana.ts.net" ];
    networking.resolvconf.extraOptions = [ "timeout:2" "attempts:1" ];
  };
}
