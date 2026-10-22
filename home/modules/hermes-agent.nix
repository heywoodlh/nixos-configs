{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.hermes;
  homeDir = if config ? home then config.home.homeDirectory else "~";
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
  remoteType = submodule {
    options = {
      enable = mkOption {
        default = false;
        description = "Expose the Hermes dashboard and API server to remote Tailscale clients.";
        type = bool;
      };
      host = mkOption {
        default = "";
        description = "Tailscale DNS name used to bind and access the remote Hermes endpoint.";
        type = str;
      };
      dashboardPort = mkOption {
        default = 9119;
        description = "Port for the remote Hermes dashboard.";
        type = port;
      };
      apiPort = mkOption {
        default = 8642;
        description = "Port for the OpenAI-compatible Hermes Agent API server.";
        type = port;
      };
      credentialsFile = mkOption {
        default = "${homeDir}/.config/hermes/remote.env";
        description = "Runtime environment file containing remote dashboard and API credentials.";
        type = str;
      };
    };
  };
  remoteCredentialsSetup = pkgs.writeShellScriptBin "hermes-remote-credentials-setup" ''
    set -euo pipefail
    credentials_file="${cfg.remote.credentialsFile}"
    mkdir -p "$(dirname "$credentials_file")"
    umask 077
    printf 'Dashboard/API username: ' >&2
    IFS= read -r username
    printf 'Dashboard/API password: ' >&2
    stty -echo
    IFS= read -r password
    stty echo
    printf '\n' >&2
    auth_secret="$(${pkgs.openssl}/bin/openssl rand -base64 32)"
    cat > "$credentials_file" <<EOF
    API_SERVER_KEY=$password
    HERMES_DASHBOARD_BASIC_AUTH_USERNAME=$username
    HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=$password
    HERMES_DASHBOARD_BASIC_AUTH_SECRET=$auth_secret
    EOF
    chmod 600 "$credentials_file"
    ${pkgs.systemd}/bin/systemctl --user restart hermes-agent.service hermes-backend.service
  '';
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
in
{
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
        default = { };
        description = "Extra settings to pass to services.hermes-agent.settings.";
        type = attrs;
      };
      environment = mkOption {
        default = { };
        description = "Extra environment vars to pass to services.hermes-agent.environment.";
        type = attrs;
      };
      environmentFiles = mkOption {
        default = [ ];
        description = ''
          Environment files to provide hermes services.
        '';
        type = listOf str;
      };
      dockerDir = mkOption {
        default = "${homeDir}/Documents/hermes";
        description = ''
          Directory to use for `docker compose` project for Hermes.
        '';
      };
      dashboard = mkOption {
        default = { };
        description = "Hermes dashboard configuration.";
        type = dashboardType;
      };
      remote = mkOption {
        default = { };
        description = "Remote Hermes dashboard and OpenAI-compatible API configuration.";
        type = remoteType;
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
        assertion = (cfg.dashboard.enable && !cfg.remote.enable) -> cfg.dashboard.address != "";
        message = "heywoodlh.home.hermes.dashboard.address must be set when heywoodlh.home.hermes.dashboard.enable is true.";
      }
      {
        assertion = cfg.remote.enable -> cfg.remote.host != "";
        message = "heywoodlh.home.hermes.remote.host must be set when heywoodlh.home.hermes.remote.enable is true.";
      }
    ];

    programs.hermes-agent.enable = true;
    services.hermes-agent = {
      enable = true;
      gateway.enable = true;
      backend = lib.optionalAttrs (cfg.dashboard.enable || cfg.remote.enable) {
        mode = "dashboard";
        host = if cfg.remote.enable then cfg.remote.host else cfg.dashboard.address;
        port = if cfg.remote.enable then cfg.remote.dashboardPort else 9119;
        waitFor = if cfg.remote.enable then "hostname" else null;
      };
      settings = {
        model = cfg.model;
      }
      // cfg.settings;
      environment = {
        CAMOFOX_URL = "http://localhost:9377";
      }
      // lib.optionalAttrs cfg.remote.enable {
        API_SERVER_ENABLED = "true";
        API_SERVER_HOST = cfg.remote.host;
        API_SERVER_PORT = toString cfg.remote.apiPort;
      }
      // cfg.environment;
      environmentFiles =
        cfg.environmentFiles ++ lib.optionals cfg.remote.enable [ cfg.remote.credentialsFile ];
      extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.systemd ];
    };

    home.packages =
      with pkgs;
      [
        dockerComposeUp
      ]
      ++ lib.optionals cfg.remote.enable [
        remoteCredentialsSetup
      ]
      ++ lib.optionals (cfg.signal) [
        signal-cli
      ];

    home.activation.hermes-remote-credentials-file = lib.mkIf cfg.remote.enable ''
      ${pkgs.coreutils}/bin/mkdir -p "${homeDir}/.config/hermes"
      ${pkgs.coreutils}/bin/touch "${cfg.remote.credentialsFile}"
      ${pkgs.coreutils}/bin/chmod 600 "${cfg.remote.credentialsFile}"
    '';

    systemd.user.services.hermes-agent.Service = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.remote.enable) {
      Environment = lib.mkAfter [
        "API_SERVER_ENABLED=true"
        "API_SERVER_HOST=${cfg.remote.host}"
        "API_SERVER_PORT=${toString cfg.remote.apiPort}"
      ];
      EnvironmentFile = [ cfg.remote.credentialsFile ];
    };
    systemd.user.services.hermes-backend.Service = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.remote.enable) {
      EnvironmentFile = [ cfg.remote.credentialsFile ];
    };

    launchd.agents = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
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

    systemd.user.services.signal-cli-daemon = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.signal) {
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

    home.activation.hermes-containers = ''
      ${dockerComposeUp}/bin/hermes-containers.sh
    '';
  };
}
