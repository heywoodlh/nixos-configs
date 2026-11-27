{
  config,
  lib,
  pkgs,
  nixtop-source,
  ...
}:
with lib; let
  cfg = config.heywoodlh.nixos.remote-desktop;
  user = cfg.user;
  homeDir = config.users.users.${user}.home;
  runtimeDir = "/run/user/${toString cfg.uid}";
  hostname = "${config.networking.hostName}.barn-banana.ts.net";
  headlessService = "${user}-niri";
  # Selkies' pixelflux creates a virtual Wayland compositor here; niri runs
  # nested inside it and publishes its own socket on the next index.
  selkiesDisplay = "wayland-1";
  niriDisplay = "wayland-2";
  sessionUnits = ["display-manager.service"] ++ optional cfg.headless.enable "${headlessService}.service";
  selkies = pkgs.callPackage "${nixtop-source}/pkgs/selkies/package.nix" {};
  wayvnc = pkgs.wayvnc.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        "${nixtop-source}/nixosModules/containerServices/nixtop/wayvnc-recapture-on-resize.patch"
      ];
  });
  vncResize = pkgs.writers.writePython3 "${user}-vnc-resize" {
    libraries = [pkgs.python3Packages.aiohttp];
    flakeIgnore = ["E501"];
  } (builtins.readFile "${nixtop-source}/nixosModules/containerServices/nixtop/vnc-resize.py");
  killWayvnc = pkgs.writeShellScript "${user}-wayvnc-kill" ''
    ${pkgs.procps}/bin/pkill -u ${user} -x wayvnc || true
  '';
  findSocket = ''
    for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
      if [ -S "$socket" ]; then
        WAYLAND_DISPLAY="''${socket##*/}"
        break
      fi
    done
  '';
  waitForDisplay = display: ''
    for _ in {1..300}; do
      [ -S "$XDG_RUNTIME_DIR/${display}" ] && break
      ${pkgs.coreutils}/bin/sleep 0.1
    done
    if [ ! -S "$XDG_RUNTIME_DIR/${display}" ]; then
      echo "Wayland socket ${display} in $XDG_RUNTIME_DIR never appeared" >&2
      exit 1
    fi
  '';
  waitForDesktop = ''
    WAYLAND_DISPLAY=
    for _ in {1..300}; do
      ${findSocket}
      [ -n "$WAYLAND_DISPLAY" ] && break
      ${pkgs.coreutils}/bin/sleep 0.1
    done
    export WAYLAND_DISPLAY
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      echo "no Wayland socket in $XDG_RUNTIME_DIR after 30s; is the desktop session running?" >&2
      exit 1
    fi
  '';
in {
  options.heywoodlh.nixos.remote-desktop = {
    enable = mkOption {
      default = false;
      description = ''
        Stream a user's Niri session over VNC and Selkies.
        The password is read from `passwordFile`; services are skipped until it exists.
      '';
      type = types.bool;
    };
    user = mkOption {
      default = config.heywoodlh.defaults.user.name;
      defaultText = literalExpression "config.heywoodlh.defaults.user.name";
      description = ''
        User whose Niri session is streamed.
      '';
      type = types.str;
    };
    uid = mkOption {
      default = config.heywoodlh.defaults.user.uid;
      defaultText = literalExpression "config.heywoodlh.defaults.user.uid";
      description = ''
        UID of the streamed user.
      '';
      type = types.int;
    };
    address = mkOption {
      default = "127.0.0.1";
      description = ''
        Address services listen on.
      '';
      type = types.str;
    };
    passwordFile = mkOption {
      default = "/opt/remote-desktop/password";
      description = ''
        File containing the VNC and Selkies basic-auth password.
      '';
      type = types.str;
    };
    vncPort = mkOption {
      default = 5900;
      description = ''
        Port wayvnc listens on.
      '';
      type = types.port;
    };
    selkiesPort = mkOption {
      default = 8082;
      description = ''
        Port Selkies listens on.
      '';
      type = types.port;
    };
    cssScaling = mkOption {
      default = false;
      description = ''
        Stream Selkies at the browser's CSS resolution instead of its device pixels, so HiDPI clients such as Retina Macs get a lower resolution that the browser scales up.
      '';
      type = types.bool;
    };
    headless = {
      enable = mkOption {
        default = false;
        description = ''
          Run Niri nested in Selkies' virtual Wayland compositor as a system service, without a display manager or physical output.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = config.users.users.${user}.uid == null || config.users.users.${user}.uid == cfg.uid;
          message = "Remote desktop user ${user} must have UID ${toString cfg.uid}.";
        }
      ];

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [cfg.vncPort];

      systemd.services = {
        selkies = {
          description = "Selkies stream of the ${config.networking.hostName} Niri session";
          wantedBy = ["multi-user.target"];
          after =
            if cfg.headless.enable
            then [
              "home-manager-${user}.service"
              "user@${toString cfg.uid}.service"
              "systemd-user-sessions.service"
              "systemd-logind.service"
            ]
            else sessionUnits;
          unitConfig.ConditionPathExists = cfg.passwordFile;
          environment =
            {
              XDG_RUNTIME_DIR = runtimeDir;
              DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
              SELKIES_GAMEPAD_ENABLED = "false";
              SELKIES_PRINTING_ENABLED = "false";
              SELKIES_ADDR = "127.0.0.1" + optionalString (cfg.address != "127.0.0.1") ",${cfg.address}";
              SELKIES_USE_CPU = "true";
            }
            // optionalAttrs cfg.cssScaling {
              SELKIES_USE_CSS_SCALING = "true";
            }
            // optionalAttrs cfg.headless.enable {
              SELKIES_WAYLAND = "true";
              SELKIES_WAYLAND_SOCKET_INDEX = "1";
            };
          serviceConfig = {
            User = user;
            PAMName = "login";
            WorkingDirectory = homeDir;
            LoadCredential = "password:${cfg.passwordFile}";
            ExecStart = pkgs.writeShellScript "${user}-selkies" ''
              ${optionalString (!cfg.headless.enable) waitForDesktop}
              SELKIES_BASIC_AUTH_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/password")
              export SELKIES_BASIC_AUTH_PASSWORD
              exec ${getExe selkies} --port=${toString cfg.selkiesPort} ${optionalString (!cfg.headless.enable) "--wayland=true --wayland-host-display=\"$WAYLAND_DISPLAY\""} --basic-auth-user=${user}
            '';
            Restart = "always";
            RestartSec = "5s";
          };
        };

        wayvnc = {
          description = "VNC access to the ${config.networking.hostName} Niri session";
          wantedBy = ["multi-user.target"];
          after =
            if cfg.headless.enable
            then ["home-manager-${user}.service" "user@${toString cfg.uid}.service" "${headlessService}.service"]
            else sessionUnits;
          requires = optional cfg.headless.enable "${headlessService}.service";
          unitConfig.ConditionPathExists = cfg.passwordFile;
          environment =
            {
              XDG_RUNTIME_DIR = runtimeDir;
              SELKIES_PORT = toString cfg.selkiesPort;
              SELKIES_USER = user;
            }
            // optionalAttrs cfg.headless.enable {
              WAYLAND_DISPLAY = niriDisplay;
            };
          serviceConfig = {
            User = user;
            PAMName = "login";
            WorkingDirectory = homeDir;
            LoadCredential = "password:${cfg.passwordFile}";
            StateDirectory = "${user}-wayvnc";
            StateDirectoryMode = "0700";
            RuntimeDirectory = "${user}-wayvnc";
            RuntimeDirectoryMode = "0700";
            UMask = "0077";
            ExecStartPre = killWayvnc;
            ExecStopPost = killWayvnc;
            ExecStart = pkgs.writeShellScript "${user}-wayvnc" ''
              key="$STATE_DIRECTORY/rsa.pem"
              [ -e "$key" ] || ${getExe pkgs.openssl} genrsa -traditional -out "$key" 4096
              cert="$STATE_DIRECTORY/tls-cert.pem"
              tlsKey="$STATE_DIRECTORY/tls-key.pem"
              [ -e "$cert" ] || ${getExe pkgs.openssl} req -x509 -newkey ec \
                -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 3650 \
                -subj "/CN=${hostname}" \
                -addext "subjectAltName=DNS:${hostname}" \
                -keyout "$tlsKey" -out "$cert"
              ${
                if cfg.headless.enable
                then waitForDisplay niriDisplay
                else waitForDesktop
              }
              ${pkgs.coreutils}/bin/cat >"$RUNTIME_DIRECTORY/config" <<EOF
              address=${cfg.address}
              port=${toString cfg.vncPort}
              enable_auth=true
              username=${user}
              password=$(<"$CREDENTIALS_DIRECTORY/password")
              rsa_private_key_file=$key
              certificate_file=$cert
              private_key_file=$tlsKey
              EOF
              exec ${vncResize} ${getExe wayvnc} -L debug -C "$RUNTIME_DIRECTORY/config"
            '';
            Restart = "always";
            RestartSec = "5s";
          };
        };
      };
    }

    (mkIf cfg.headless.enable {
      users.users.${user}.extraGroups = ["render" "video"];

      heywoodlh.niri.enable = true;

      systemd.services.${headlessService} = {
        description = "niri session for ${user} inside the Selkies virtual display";
        wantedBy = ["multi-user.target"];
        after = [
          "selkies.service"
          "home-manager-${user}.service"
          "user@${toString cfg.uid}.service"
          "systemd-user-sessions.service"
          "systemd-logind.service"
        ];
        requires = ["selkies.service"];
        environment = {
          XDG_RUNTIME_DIR = runtimeDir;
          DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
          WAYLAND_DISPLAY = selkiesDisplay;
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "niri";
        };
        serviceConfig = {
          User = user;
          PAMName = "login";
          WorkingDirectory = homeDir;
          ExecStart = pkgs.writeShellScript "${user}-niri" ''
            for _ in {1..300}; do
              [ -S "$XDG_RUNTIME_DIR/${selkiesDisplay}" ] && exec ${pkgs.niri}/bin/niri
              ${pkgs.coreutils}/bin/sleep 0.1
            done
            echo "Selkies Wayland socket ${selkiesDisplay} never appeared" >&2
            exit 1
          '';
          Restart = "always";
          RestartSec = "5s";
        };
      };

      home-manager.users.${user} = {
        heywoodlh.home.niri.enable = true;
        heywoodlh.home.niri.lockScreen = false;
        heywoodlh.home.niri.idleScreenOff = false;
        heywoodlh.home.keyring.autoUnlock = true;
      };
    })
  ]);
}
