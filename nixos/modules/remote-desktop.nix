{ config, lib, pkgs, nixtop-source, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.remote-desktop;
  user = cfg.user;
  homeDir = config.users.users.${user}.home;
  runtimeDir = "/run/user/${toString cfg.uid}";
  hostname = "${config.networking.hostName}.barn-banana.ts.net";
  headlessService = "${user}-hyprland";
  headlessTty = "tty${toString cfg.headless.vt}";
  sessionUnits = [ "display-manager.service" ] ++ optional cfg.headless.enable "${headlessService}.service";
  selkies = pkgs.callPackage "${nixtop-source}/pkgs/selkies/package.nix" { };
  wayvnc = pkgs.wayvnc.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      "${nixtop-source}/nixosModules/containerServices/nixtop/wayvnc-recapture-on-resize.patch"
    ];
  });
  vncResize = pkgs.writers.writePython3 "${user}-vnc-resize" {
    libraries = [ pkgs.python3Packages.aiohttp ];
    flakeIgnore = [ "E501" ];
  } (builtins.readFile "${nixtop-source}/nixosModules/containerServices/nixtop/vnc-resize.py");
  killWayvnc = pkgs.writeShellScript "${user}-wayvnc-kill" ''
    ${pkgs.procps}/bin/pkill -u ${user} -x wayvnc || true
  '';
  findSocket =
    if cfg.headless.enable then ''
      pid=$(${config.systemd.package}/bin/systemctl show -p MainPID --value ${headlessService}.service)
      if [ "$pid" != 0 ]; then
        socket=$(${pkgs.hyprland}/bin/hyprctl instances -j | ${getExe pkgs.jq} -r --argjson pid "$pid" '.[] | select(.pid == $pid) | .wl_socket')
        if [ -n "$socket" ] && [ -S "$XDG_RUNTIME_DIR/$socket" ]; then
          WAYLAND_DISPLAY="$socket"
        fi
      fi
    '' else ''
      for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
        if [ -S "$socket" ]; then
          WAYLAND_DISPLAY="''${socket##*/}"
          break
        fi
      done
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
        Stream a user's Hyprland session over VNC and Selkies.
        The password is read from `passwordFile`; services are skipped until it exists.
      '';
      type = types.bool;
    };
    user = mkOption {
      default = config.heywoodlh.defaults.user.name;
      defaultText = literalExpression "config.heywoodlh.defaults.user.name";
      description = ''
        User whose Hyprland session is streamed.
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
          Run a headless Hyprland session for the user as a system service instead of relying on a display manager.
        '';
        type = types.bool;
      };
      output = mkOption {
        default = "HEADLESS-${toUpper user}";
        defaultText = literalExpression ''"HEADLESS-''${toUpper config.heywoodlh.nixos.remote-desktop.user}"'';
        description = ''
          Name of the headless Hyprland output.
        '';
        type = types.str;
      };
      vt = mkOption {
        default = 1;
        description = ''
          Virtual terminal the headless session runs on so logind gives it a seat.
          Its getty is stopped, and no display manager may run on the same seat.
        '';
        type = types.ints.between 1 63;
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

      networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ cfg.vncPort ];

      systemd.services = {
        selkies = {
          description = "Selkies stream of the ${config.networking.hostName} Hyprland session";
          wantedBy = [ "multi-user.target" ];
          after = sessionUnits;
          bindsTo = optional cfg.headless.enable "${headlessService}.service";
          unitConfig.ConditionPathExists = cfg.passwordFile;
          environment = {
            XDG_RUNTIME_DIR = runtimeDir;
            DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
            SELKIES_GAMEPAD_ENABLED = "false";
            SELKIES_PRINTING_ENABLED = "false";
            SELKIES_ADDR = "127.0.0.1" + optionalString (cfg.address != "127.0.0.1") ",${cfg.address}";
            SELKIES_USE_CPU = "true";
          } // optionalAttrs cfg.cssScaling {
            SELKIES_USE_CSS_SCALING = "true";
          };
          serviceConfig = {
            User = user;
            PAMName = "login";
            WorkingDirectory = homeDir;
            LoadCredential = "password:${cfg.passwordFile}";
            ExecStart = pkgs.writeShellScript "${user}-selkies" ''
              ${waitForDesktop}
              SELKIES_BASIC_AUTH_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/password")
              export SELKIES_BASIC_AUTH_PASSWORD
              exec ${getExe selkies} --port=${toString cfg.selkiesPort} \
                --wayland=true --wayland-host-display="$WAYLAND_DISPLAY" \
                --basic-auth-user=${user}
            '';
            Restart = "always";
            RestartSec = "5s";
          };
        };

        wayvnc = {
          description = "VNC access to the ${config.networking.hostName} Hyprland session";
          wantedBy = [ "multi-user.target" ];
          after = sessionUnits;
          bindsTo = optional cfg.headless.enable "${headlessService}.service";
          unitConfig.ConditionPathExists = cfg.passwordFile;
          environment = {
            XDG_RUNTIME_DIR = runtimeDir;
            SELKIES_PORT = toString cfg.selkiesPort;
            SELKIES_USER = user;
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
              ${waitForDesktop}
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
      users.users.${user}.extraGroups = [ "render" "video" ];

      systemd.targets.getty.wants = mkIf (cfg.headless.vt == 1) (mkForce [ ]);

      systemd.services.${headlessService} = {
        description = "Headless Hyprland session for ${user}";
        wantedBy = [ "multi-user.target" ];
        after = [
          "home-manager-${user}.service"
          "user@${toString cfg.uid}.service"
          "systemd-user-sessions.service"
          "systemd-logind.service"
          "getty@${headlessTty}.service"
        ];
        wants = [
          "home-manager-${user}.service"
          "user@${toString cfg.uid}.service"
          "systemd-logind.service"
          "selkies.service"
          "wayvnc.service"
        ];
        conflicts = [ "getty@${headlessTty}.service" ];
        environment = {
          XDG_RUNTIME_DIR = runtimeDir;
          DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
          XDG_SEAT = "seat0";
          XDG_VTNR = toString cfg.headless.vt;
          AQ_NO_KMS_REQUIREMENT = "1";
        };
        serviceConfig = {
          User = user;
          PAMName = "login";
          WorkingDirectory = homeDir;
          ExecStart = "${pkgs.hyprland}/bin/Hyprland";
          TTYPath = "/dev/${headlessTty}";
          TTYReset = true;
          TTYVHangup = true;
          TTYVTDisallocate = true;
          StandardInput = "tty-fail";
          StandardOutput = "journal";
          StandardError = "journal";
          UtmpIdentifier = headlessTty;
          UtmpMode = "user";
          Restart = "always";
          RestartSec = "5s";
        };
      };

      home-manager.users.${user} = {
        heywoodlh.home.hyprland = true;
        heywoodlh.home.keyring.autoUnlock = true;
        wayland.windowManager.hyprland.systemd.enable = false;
        wayland.windowManager.hyprland.extraConfig = ''
          hl.monitor({ output = "${cfg.headless.output}", mode = "preferred", position = "0x0", scale = 1 })
          hl.on("hyprland.start", function()
            hl.exec_cmd("${pkgs.hyprland}/bin/hyprctl output create headless ${cfg.headless.output}")
          end)
        '';
      };
    })
  ]);
}
