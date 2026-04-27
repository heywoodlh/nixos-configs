{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.scrutiny;
in {
  options.heywoodlh.nixos.scrutiny = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh scrutiny monitoring configuration.
        Remember to run `sudo systemctl start scrutiny-collector.timer` for initial dashboard population.
      '';
      type = types.bool;
    };
    port = mkOption {
      default = 3050;
      description = ''
        Port for scrutiny web service.
      '';
      type = types.int;
    };
    ntfy = mkOption {
      default = "";
      description = ''
        URL for NTFY notifications.
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # Restrict scrutiny to tailscale
    networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.port ];

    # Remember to run `sudo systemctl start scrutiny-collector.timer` for initial dashboard population.
    services.scrutiny = {
      enable = true;
      collector.enable = true;
      settings = {
        web.listen.port = cfg.port;
        web.listen.basepath = "/${config.networking.hostName}";
        notify.urls = optionals (cfg.ntfy != "") [
          cfg.ntfy
        ];
      };
    };
  };
}
