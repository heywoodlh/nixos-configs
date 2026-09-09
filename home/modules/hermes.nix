{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.hermes;
  signalCliDaemon = pkgs.writeShellScript "signal-cli-daemon.sh" ''
    set -a
    ${concatMapStringsSep "\n" (f: ''source "${f}"'') cfg.environmentFiles}
    set +a

    if [[ -z "$SIGNAL_ACCOUNT" ]]
    then
      echo "SIGNAL_ACCOUNT not set, exiting"
      exit 0
    fi

    exec ${pkgs.signal-cli}/bin/signal-cli --account "$SIGNAL_ACCOUNT" daemon --http 127.0.0.1:9000
  '';
  dockerComposeUp = pkgs.writeShellScriptBin "hermes-containers.sh" ''
    if ${pkgs.docker-client}/bin/docker ps &>/dev/null
    then
      mkdir -p "${cfg.dockerDir}"
      ${pkgs.docker-client}/bin/docker compose --project-directory "${cfg.dockerDir}" --file ${compose} up -d
    fi
  '';
  dashboardType = submodule {
    options = {
      enable = mkOption {
        default = false;
        description = ''
          Enable the hermes-agent web dashboard.
        '';
        type = bool;
      };
      address = mkOption {
        default = "";
        description = ''
          Address for the dashboard to bind to. Passed to hermes as
          `--host`. Required if the dashboard is enabled.
          Example: "nixos-ops.barn-banana.ts.net".
        '';
        type = str;
      };
    };
  };
  compose = pkgs.writeText "compose.yaml" ''
    services:
      camofox:
        image: ghcr.io/jo-inc/camofox-browser:latest
        ports:
          - "127.0.0.1:9377:9377"
        pull_policy: every_12h
        restart: unless-stopped
        healthcheck:
          test: ["CMD-SHELL", "curl -fsS --max-time 5 http://localhost:9377/ | grep -q '\"browserRunning\":true'"]
          interval: 60s
          timeout: 10s
          retries: 3
          start_period: 30s
          start_interval: 5s
  '';
in {
  options = {
    heywoodlh.home.hermes = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh hermes-agent configuration.
        '';
        type = types.bool;
      };
      model = mkOption {
        default = {
          default = "deepseek/deepseek-v4-flash-0731";
          provider = "openrouter";
        };
        description = "Model configuration.";
        type = attrs;
      };
      settings = mkOption {
        default = {};
        description = "Extra settings to pass to services.hermes-agent.settings.";
        type = attrs;
      };
      environment = mkOption {
        default = {};
        description = "Extra environment vars to pass to services.hermes-agent.environment.";
        type = attrs;
      };
      environmentFiles = mkOption {
        default = [];
        description = ''
          Environment files to provide hermes services.
        '';
        type = listOf str;
      };
      dockerDir = mkOption {
        default = "${config.home.homeDirectory}/Documents/hermes";
        description = ''
          Directory to use for `docker compose` project for Hermes.
        '';
      };
      dashboard = mkOption {
        default = {};
        description = "Hermes dashboard configuration.";
        type = dashboardType;
      };
      signal = mkOption {
        default = true;
        description = ''
          Enable heywoodlh hermes-agent signal-cli configuration.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.dashboard.enable -> cfg.dashboard.address != "";
        message = "heywoodlh.home.hermes.dashboard.address must be set when heywoodlh.home.hermes.dashboard.enable is true.";
      }
    ];

    programs.hermes-agent.enable = true;
    services.hermes-agent = {
      enable = true;
      gateway.enable = true;
      backend = lib.optionalAttrs cfg.dashboard.enable {
        mode = "dashboard";
        host = cfg.dashboard.address;
      };
      settings = {
        model = cfg.model;
      } // cfg.settings;
      environment = {
        CAMOFOX_URL = "http://localhost:9377";
      } // cfg.environment;
      environmentFiles = cfg.environmentFiles;
    };

    home.packages = with pkgs; [
      dockerComposeUp
    ] ++ lib.optionals (cfg.signal) [
      signal-cli
    ];

    launchd.agents = lib.optionalAttrs pkgs.stdenv.isDarwin {
      signal-cli-daemon = {
        enable = cfg.signal;
        config = {
          ProgramArguments = [ "${signalCliDaemon}" ];
          RunAtLoad = true;
          KeepAlive = true;
          AbandonProcessGroup = true;
        };
      };
    };

    systemd.user = lib.optionalAttrs (pkgs.stdenv.isLinux && cfg.signal) {
      enable = true;
      services = {
        signal-cli-daemon = {
          Unit = {
            Description = "signal-cli HTTP daemon";
          };
          Install = {
            WantedBy = [ "default.target" ];
          };
          Service = {
            ExecStart = "${signalCliDaemon}";
            Restart = "on-failure";
          };
        };
      };
    };

    home.activation.hermes-containers = ''
      ${dockerComposeUp}/bin/hermes-containers.sh
    '';
  };
}
