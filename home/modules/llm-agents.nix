{
  config,
  lib,
  pkgs,
  nixpkgs-edge,
  ...
}:
with lib;
with lib.types; let
  cfg = config.heywoodlh.home.hermes;
  t3Cfg = config.heywoodlh.home.t3;
  # Nix-built library closure for T3 Code's runtime-downloaded
  # chrome-headless-shell (a generic Linux binary that fails on NixOS).
  t3ChromeDeps = pkgs.symlinkJoin {
    name = "t3-chrome-headless-shell-deps";
    paths =
      map pkgs.lib.getLib [
        pkgs.alsa-lib
        pkgs.atk
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.dbus
        pkgs.expat
        pkgs.mesa
        pkgs.glib
        pkgs.nspr
        pkgs.nss
        pkgs.systemd
        pkgs.xorg.libX11
        pkgs.xorg.libxcb
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXdamage
        pkgs.xorg.libXext
        pkgs.xorg.libXfixes
        pkgs.xorg.libXrandr
        pkgs.libxkbcommon
      ]
      ++ [pkgs.mesa-libgbm pkgs.glibc];
  };
  # Idempotently patch every downloaded chrome-headless-shell so it can run
  # on NixOS: set the ELF interpreter and an rpath against t3ChromeDeps.
  # Keeps an unpatched .orig backup per version; re-runs after T3 updates.
  t3PatchBrowser = pkgs.writeShellScriptBin "t3-patch-browser" ''
    set -euo pipefail
    patched=0
    for bin in "$HOME"/.t3/tools/chrome-headless-shell/linux64/*/chrome-headless-shell; do
      [ -e "$bin" ] || continue
      if [ -e "$bin.orig" ]; then
        # Already backed up: re-patch from the pristine copy.
        cp -f "$bin.orig" "$bin"
      else
        cp -f "$bin" "$bin.orig"
      fi
      ${pkgs.patchelf}/bin/patchelf \
        --set-interpreter "${pkgs.glibc}/lib/ld-linux-x86-64.so.2" \
        --set-rpath "${t3ChromeDeps}/lib" "$bin"
      patched=$((patched + 1))
    done
    echo "t3-patch-browser: patched $patched chrome-headless-shell binaries"
  '';
  # Launch wrapper: patch any newly downloaded browser, then run the server.
  t3Serve = pkgs.writeShellScriptBin "t3-serve-patched" ''
    ${t3PatchBrowser}/bin/t3-patch-browser
    exec ${t3Cfg.package}/bin/t3 serve --mode web --host ${t3Cfg.address} --port ${toString t3Cfg.port} "$@"
  '';
  t3ApiHost =
    if builtins.elem t3Cfg.address ["0.0.0.0" "::"]
    then "127.0.0.1"
    else t3Cfg.address;
  t3NtfyBridge = pkgs.writeShellScriptBin "t3-ntfy-bridge" ''
    exec ${pkgs.nodejs}/bin/node ${./t3-ntfy-bridge.mjs} "$@"
  '';
  homeDir =
    if config ? home
    then config.home.homeDirectory
    else "~";
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
in {
  options = {
    heywoodlh.home.t3 = {
      enable = mkOption {
        default = false;
        description = "Run the T3 Code web UI as a user service.";
        type = bool;
      };
      package = mkOption {
        default = nixpkgs-edge.legacyPackages.${pkgs.stdenv.hostPlatform.system}.t3code;
        defaultText = literalExpression "nixpkgs-edge.legacyPackages.\${system}.t3code";
        description = "T3 Code package to use.";
        type = package;
      };
      address = mkOption {
        default = "0.0.0.0";
        description = "Address for the T3 Code web UI to bind to.";
        type = str;
      };
      port = mkOption {
        default = 3773;
        description = "Port for the T3 Code web UI.";
        type = port;
      };
      notifications.ntfy = {
        enable = mkOption {
          default = false;
          description = "Send T3 Code thread notifications to an ntfy topic.";
          type = bool;
        };
        url = mkOption {
          default = "";
          description = "ntfy topic URL to publish notifications to.";
          type = str;
        };
        pollInterval = mkOption {
          default = 10;
          description = "Seconds between T3 Code shell snapshot polls.";
          type = ints.positive;
        };
        tokenFile = mkOption {
          default = null;
          description = "Optional file containing an ntfy access token for a protected topic.";
          type = nullOr str;
        };
      };
      hermes = {
        enable = mkOption {
          default = false;
          description = "Enable Hermes ACP as a local T3 Code provider.";
          type = bool;
        };
      };
    };
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
      extraPlugins = mkOption {
        default = [];
        description = "Extra plugins to pass to services.hermes-agent.extraPlugins.";
        type = listOf package;
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
        default = "${homeDir}/Documents/hermes";
        description = ''
          Directory to use for `docker compose` project for Hermes.
        '';
      };
      dashboard = mkOption {
        default = {};
        description = "Hermes dashboard configuration.";
        type = dashboardType;
      };
      remote = mkOption {
        default = {};
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

  config = mkMerge [
    (mkIf cfg.enable {
      assertions = [
        {
          assertion = (cfg.dashboard.enable && !cfg.remote.enable) -> cfg.dashboard.address != "";
          message = "heywoodlh.home.hermes.dashboard.address must be set when heywoodlh.home.hermes.dashboard.enable is true.";
        }
        {
          assertion = cfg.remote.enable -> cfg.remote.host != "";
          message = "heywoodlh.home.hermes.remote.host must be set when heywoodlh.home.hermes.remote.enable is true.";
        }
        {
          assertion = !t3Cfg.hermes.enable || cfg.enable;
          message = "heywoodlh.home.t3.hermes.enable requires heywoodlh.home.hermes.enable.";
        }
      ];

      programs.hermes-agent.enable = true;
      services.hermes-agent = {
        enable = true;
        gateway.enable = true;
        backend = lib.optionalAttrs (cfg.dashboard.enable || cfg.remote.enable) {
          mode = "dashboard";
          host =
            if cfg.remote.enable
            then cfg.remote.host
            else cfg.dashboard.address;
          port =
            if cfg.remote.enable
            then cfg.remote.dashboardPort
            else 9119;
          waitFor =
            if cfg.remote.enable
            then "hostname"
            else null;
        };
        extraPlugins = cfg.extraPlugins;
        settings =
          {
            model = cfg.model;
          }
          // cfg.settings;
        environment =
          {
            CAMOFOX_URL = "http://localhost:9377";
          }
          // lib.optionalAttrs cfg.remote.enable {
            API_SERVER_ENABLED = "true";
            API_SERVER_HOST = cfg.remote.host;
            API_SERVER_PORT = toString cfg.remote.apiPort;
          }
          // cfg.environment;
        environmentFiles =
          cfg.environmentFiles ++ lib.optionals cfg.remote.enable [cfg.remote.credentialsFile];
        extraPackages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [pkgs.systemd];
      };

      home.packages = with pkgs;
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
        EnvironmentFile = [cfg.remote.credentialsFile];
      };
      systemd.user.services.hermes-backend.Service = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && cfg.remote.enable) {
        EnvironmentFile = [cfg.remote.credentialsFile];
      };

      launchd.agents = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        signal-cli-daemon = {
          enable = cfg.signal;
          config = {
            ProgramArguments = ["${signalCliDaemon}"];
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
          WantedBy = ["default.target"];
        };
        Service = {
          ExecStart = "${signalCliDaemon}";
          Restart = "on-failure";
        };
      };

      home.activation.hermes-containers = ''
        ${dockerComposeUp}/bin/hermes-containers.sh
      '';
    })
    (mkIf t3Cfg.enable {
      assertions = [
        {
          assertion = !t3Cfg.notifications.ntfy.enable || t3Cfg.notifications.ntfy.url != "";
          message = "heywoodlh.home.t3.notifications.ntfy.url must be set when ntfy notifications are enabled.";
        }
      ];

      programs.t3code = {
        enable = true;
        package = t3Cfg.package;
        userSettings = lib.optionalAttrs t3Cfg.hermes.enable {
          providerInstances.hermes = {
            driver = "acpRegistry";
            displayName = "Hermes";
            enabled = true;
            config = {
              source = "local";
              commandPath = "${config.programs.hermes-agent.package}/bin/hermes";
              commandArgs = ["acp"];
            };
          };
        };
      };

      systemd.user.services.t3code = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        Unit.Description = "T3 Code web UI";
        Service = {
          ExecStart = "${t3Serve}/bin/t3-serve-patched";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = ["default.target"];
      };

      systemd.user.services.t3-ntfy = lib.mkIf (pkgs.stdenv.hostPlatform.isLinux && t3Cfg.notifications.ntfy.enable) {
        Unit = {
          Description = "T3 Code ntfy notifications";
          After = ["t3code.service"];
        };
        Service = {
          ExecStart = "${t3NtfyBridge}/bin/t3-ntfy-bridge";
          Restart = "on-failure";
          RestartSec = "15s";
          Environment =
            [
              "T3_NOTIFY_BASE_URL=http://${t3ApiHost}:${toString t3Cfg.port}"
              "T3_NOTIFY_NTFY_URL=${t3Cfg.notifications.ntfy.url}"
              "T3_NOTIFY_T3_BIN=${t3Cfg.package}/bin/t3"
              "T3_NOTIFY_POLL_SECONDS=${toString t3Cfg.notifications.ntfy.pollInterval}"
            ]
            ++ lib.optional (t3Cfg.notifications.ntfy.tokenFile != null) "T3_NOTIFY_NTFY_TOKEN_FILE=${t3Cfg.notifications.ntfy.tokenFile}";
        };
        Install.WantedBy = ["default.target"];
      };

      launchd.agents.t3-ntfy = lib.optionalAttrs (pkgs.stdenv.hostPlatform.isDarwin && t3Cfg.notifications.ntfy.enable) {
        enable = true;
        config = {
          ProgramArguments = ["${t3NtfyBridge}/bin/t3-ntfy-bridge"];
          EnvironmentVariables =
            {
              T3_NOTIFY_BASE_URL = "http://${t3ApiHost}:${toString t3Cfg.port}";
              T3_NOTIFY_NTFY_URL = t3Cfg.notifications.ntfy.url;
              T3_NOTIFY_T3_BIN = "${t3Cfg.package}/bin/t3";
              T3_NOTIFY_POLL_SECONDS = toString t3Cfg.notifications.ntfy.pollInterval;
            }
            // lib.optionalAttrs (t3Cfg.notifications.ntfy.tokenFile != null) {
              T3_NOTIFY_NTFY_TOKEN_FILE = t3Cfg.notifications.ntfy.tokenFile;
            };
          RunAtLoad = true;
          KeepAlive = true;
        };
      };

      launchd.agents.t3code = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        enable = true;
        config = {
          ProgramArguments = [
            "${t3Cfg.package}/bin/t3"
            "serve"
            "--mode"
            "web"
            "--host"
            t3Cfg.address
            "--port"
            (toString t3Cfg.port)
          ];
          RunAtLoad = true;
          KeepAlive = true;
        };
      };
    })
  ];
}
