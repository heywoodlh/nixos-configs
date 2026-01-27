{ pkgs, config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.rayhunter;
in {
  options.heywoodlh.rayhunter = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh rayhunter ntfy reverse proxy configuration.
      '';
      type = bool;
    };
    ntfy = mkOption {
      default = "";
      description = ''
        NTFY URL to proxy.
      '';
      type = str;
    };
    user = mkOption {
      default = "rayhunter";
      description = ''
        User to run the reverse proxy.
      '';
      type = str;
    };
    interface = mkOption {
      default = "";
      description = ''
        RayHunter USB interface name.
      '';
      type = str;
    };
    port = mkOption {
      default = 6767;
      description = ''
        Reverse proxy port.
      '';
      type = int;
    };
  };

  config = mkIf cfg.enable {
    users.groups."${cfg.user}" = {};
    users.users."${cfg.user}" = {
      group = "${cfg.user}";
      home = "/var/rayhunter-proxy";
      createHome = true;
      isSystemUser = true;
    };

    networking.firewall.interfaces.${cfg.interface}.allowedTCPPorts = [
      cfg.port
    ];

    boot.kernel.sysctl."net.ipv6.conf.${cfg.interface}.disable_ipv6" = true;

    system.activationScripts.delRayHunterRoute = ''
      ${pkgs.net-tools}/bin/route del -net 0.0.0.0 netmask 0.0.0.0 dev ${cfg.interface}
    '';

    systemd.services.rayhunter-proxy = {
      enable = true;
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      description = "Rayhunter reverse proxy";
      serviceConfig = {
        Type = "simple";
        User = "${cfg.user}";
        ExecStart = ''
          ${pkgs.caddy}/bin/caddy reverse-proxy --disable-redirects --insecure --from :${builtins.toString cfg.port} --to ${cfg.ntfy}
        '';
      };
    };
  };
}
