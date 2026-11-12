{ config, lib, pkgs, nixtop-source, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.remote-desktop;
  user = cfg.user;
  homeDir = config.users.users.${user}.home;
  runtimeDir = "/run/user/${toString cfg.uid}";
  hostname = "${config.networking.hostName}.barn-banana.ts.net";
  headlessService = "${user}-hyprland";
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
  waitForDesktop = ''
    for _ in {1..300}; do
      for socket in "$XDG_RUNTIME_DIR"/wayland-*; do
        if [ -S "$socket" ]; then
          export WAYLAND_DISPLAY="''${socket##*/}"
          break 2
        fi
      done
      ${pkgs.coreutils}/bin/sleep 0.1
    done
    [ -n "''${WAYLAND_DISPLAY:-}" ] || exit 1
  '';
in {
  options.heywoodlh.nixos.remote-desktop = {
    enable = mkOption {
      default = false;
      description = ''
        Stream a user's Hyprland session over VNC (Tailscale) and Selkies (localhost).
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
    tailscaleIP = mkOption {
      description = ''
        Tailscale address wayvnc listens on.
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
        Port Selkies listens on (127.0.0.1 only).
      '';
      type = types.port;
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
          unitConfig.ConditionPathExists = cfg.passwordFile;
          environment = {
            XDG_RUNTIME_DIR = runtimeDir;
            DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
            SELKIES_GAMEPAD_ENABLED = "false";
            SELKIES_PRINTING_ENABLED = "false";
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
              exec ${getExe selkies} --addr=127.0.0.1 --port=${toString cfg.selkiesPort} \
                --wayland=true --wayland-host-display="$WAYLAND_DISPLAY" \
                --basic-auth-user=${user}
            '';
            Restart = "always";
            RestartSec = "5s";
          };
        };

        wayvnc = {
          description = "VNC access to the ${config.networking.hostName} Hyprland session over Tailscale";
          wantedBy = [ "multi-user.target" ];
          after = sessionUnits ++ [ "tailscaled.service" ];
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
              address=${cfg.tailscaleIP}
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

      systemd.services.${headlessService} = {
        description = "Headless Hyprland session for ${user}";
        wantedBy = [ "multi-user.target" ];
        after = [ "home-manager-${user}.service" "user@${toString cfg.uid}.service" ];
        requires = [ "home-manager-${user}.service" ];
        wants = [ "user@${toString cfg.uid}.service" ];
        environment = {
          XDG_RUNTIME_DIR = runtimeDir;
          DBUS_SESSION_BUS_ADDRESS = "unix:path=${runtimeDir}/bus";
          XDG_SESSION_TYPE = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
          AQ_NO_KMS_REQUIREMENT = "1";
        };
        serviceConfig = {
          User = user;
          PAMName = "login";
          WorkingDirectory = homeDir;
          ExecStart = "${pkgs.hyprland}/bin/Hyprland";
          Restart = "always";
          RestartSec = "5s";
        };
      };

      home-manager.users.${user} = {
        heywoodlh.home.hyprland = true;
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
