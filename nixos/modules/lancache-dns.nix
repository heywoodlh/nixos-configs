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
    networking.nameservers = [ cfg.server ];
    networking.search = [ "barn-banana.ts.net" ];
  };
}
