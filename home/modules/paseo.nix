{ config, lib, pkgs, paseo, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.paseo;
  paseoPkgs = paseo.packages.${pkgs.stdenv.hostPlatform.system};
  serverType = submodule {
    options = {
      enable = mkOption {
        default = false;
        description = ''
          Enable Paseo server configuration.
        '';
        type = bool;
      };
      address = mkOption {
        default = "";
        description = ''
          Server address for Paseo to listen on. Required if server enabled.
          Example: "100.101.102.103:6767".
        '';
        type = str;
      };
      webui = mkOption {
        default = false;
        description = "Enable Paseo daemon web UI.";
        type = bool;
      };
      hostnames = mkOption {
        default = [];
        description = ''
          Daemon hostnames. Passed to Paseo as a comma-separated list.
          Example: [ "myhost" ".example.com" ] or [ "true" ] for any.
        '';
        type = listOf str;
      };
    };
  };
  hostnamesArg = lib.optionalString (cfg.server.hostnames != [])
    ''--hostnames "${lib.concatStringsSep "," cfg.server.hostnames}"'';
  startPaseo = pkgs.writeShellScript "paseod" ''
    ${paseoPkgs.default}/bin/paseo daemon start --foreground --listen "${cfg.server.address}" --relay ${hostnamesArg}
  '';
in {
  options.heywoodlh.home.paseo = {
    server = mkOption {
      default = {};
      description = "Paseo server configuration.";
      type = serverType;
    };
    desktop = mkOption {
      default = false;
      description = ''
        Install Paseo desktop client.
      '';
      type = bool;
    };
    extraConf = mkOption {
      default = false;
      description = ''
        Extra configuration to add to `~/.paseo/config.json`.
      '';
      type = attrs;
    };
  };

  config = mkIf (cfg.desktop || cfg.server.enable) {
    assertions = [
      {
        assertion = cfg.server.enable -> cfg.server.address != "";
        message = "heywoodlh.home.paseo.server.address must be set when heywoodlh.home.paseo.server.enable is true.";
      }
    ];

    home.packages = [
      paseoPkgs.paseo
    ] ++ lib.optionals (cfg.desktop) [
      paseoPkgs.desktop
    ];

    launchd.agents = lib.optionalAttrs pkgs.stdenv.isDarwin {
      paseo = {
        enable = cfg.server.enable;
        config = {
          ProgramArguments = [ "${startPaseo}" ];
          RunAtLoad = true;
          StartInterval = 60; # Re-run every minute
          AbandonProcessGroup = true;
        };
      };
    };

    home.file.".paseo/config.json".text = builtins.toJSON ({
      "$schema" = "https://paseo.sh/schemas/paseo.config.v1.json";
      version = 1;
      app.baseUrl = cfg.server.address; # is overridden by the `--listen` arg, but we'll keep it
      daemon = {
        relay.enabled = true;
      };
    } // cfg.extraConf);

    systemd.user = lib.optionalAttrs pkgs.stdenv.isLinux {
      enable = true;
      services = {
        paseo = lib.optionalAttrs cfg.server.enable {
          Unit = {
            Description = "Paseo daemon service.";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            ExecStart = "${startPaseo}";
            Type = "simple";
            EnvironmentFile = "-%h/.config/paseo/.env";
            Environment = mkIf cfg.server.webui [
              "PASEO_WEB_UI_ENABLED=true"
            ];
          };
        };
      };
    };
  };
}
