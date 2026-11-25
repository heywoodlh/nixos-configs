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
      default = "100.65.18.5";
      description = "Address of the lancache DNS server.";
    };
  };

  config = mkIf cfg.enable {
    services.tailscale.extraSetFlags = [ "--accept-dns=false" ];
    # tailscaled's stub stays the fallback when lancache does not answer
    networking.nameservers = [ cfg.server "100.100.100.100" ];
    networking.search = [ "barn-banana.ts.net" ];
    networking.resolvconf.extraOptions = [ "timeout:2" "attempts:1" ];
  };
}
