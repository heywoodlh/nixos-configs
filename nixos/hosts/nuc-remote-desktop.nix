{ config, lib, pkgs, nixtop-source, ... }:

let
  user = config.heywoodlh.defaults.user.name;
  homeDir = config.heywoodlh.defaults.user.homeDir;
  uid = toString config.heywoodlh.defaults.user.uid;
  runtimeDir = "/run/user/${uid}";
  passwordFile = "/opt/remote-desktop/password";
  vncPort = 5900;
  selkiesPort = 8082;
  selkies = pkgs.callPackage "${nixtop-source}/pkgs/selkies/package.nix" { };
  wayvnc = pkgs.wayvnc.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      "${nixtop-source}/nixosModules/containerServices/nixtop/wayvnc-recapture-on-resize.patch"
    ];
  });
  vncResize = pkgs.writers.writePython3 "nuc-vnc-resize" {
    libraries = [ pkgs.python3Packages.aiohttp ];
    flakeIgnore = [ "E501" ];
  } "${nixtop-source}/nixosModules/containerServices/nixtop/vnc-resize.py";
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
  services.desktopManager.plasma6.enable = false;
  services.displayManager = {
    gdm.enable = true;
    defaultSession = "hyprland";
    autoLogin = {
      enable = true;
      user = user;
    };
  };
  heywoodlh.cosmic = lib.mkForce false;
  heywoodlh.hyprland = true;
  heywoodlh.nixos.kde.enable = false;
  heywoodlh.nixos.sunshine.enable = false;

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ vncPort ];

  systemd.services = {
    selkies = {
      description = "Selkies stream of the nixos-nuc Hyprland session";
      wantedBy = [ "multi-user.target" ];
      after = [ "display-manager.service" ];
      unitConfig.ConditionPathExists = passwordFile;
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
        LoadCredential = "password:${passwordFile}";
        ExecStart = pkgs.writeShellScript "nuc-selkies" ''
          ${waitForDesktop}
          SELKIES_BASIC_AUTH_PASSWORD=$(<"$CREDENTIALS_DIRECTORY/password")
          export SELKIES_BASIC_AUTH_PASSWORD
          exec ${lib.getExe selkies} --addr=127.0.0.1 --port=${toString selkiesPort} \
            --wayland=true --wayland-host-display="$WAYLAND_DISPLAY" \
            --basic-auth-user=${user}
        '';
        Restart = "always";
        RestartSec = "5s";
      };
    };

    wayvnc = {
      description = "VNC access to the nixos-nuc Hyprland session over Tailscale";
      wantedBy = [ "multi-user.target" ];
      after = [ "display-manager.service" "tailscaled.service" ];
      unitConfig.ConditionPathExists = passwordFile;
      environment = {
        XDG_RUNTIME_DIR = runtimeDir;
        SELKIES_PORT = toString selkiesPort;
        SELKIES_USER = user;
      };
      serviceConfig = {
        User = user;
        PAMName = "login";
        WorkingDirectory = homeDir;
        LoadCredential = "password:${passwordFile}";
        StateDirectory = "nuc-wayvnc";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "nuc-wayvnc";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";
        ExecStart = pkgs.writeShellScript "nuc-wayvnc" ''
          key="$STATE_DIRECTORY/rsa.pem"
          [ -e "$key" ] || ${lib.getExe pkgs.openssl} genrsa -traditional -out "$key" 4096
          cert="$STATE_DIRECTORY/tls-cert.pem"
          tlsKey="$STATE_DIRECTORY/tls-key.pem"
          [ -e "$cert" ] || ${lib.getExe pkgs.openssl} req -x509 -newkey ec \
            -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 3650 \
            -subj "/CN=nixos-nuc.barn-banana.ts.net" \
            -addext "subjectAltName=DNS:nixos-nuc.barn-banana.ts.net" \
            -keyout "$tlsKey" -out "$cert"
          ${waitForDesktop}
          ${pkgs.coreutils}/bin/cat >"$RUNTIME_DIRECTORY/config" <<EOF
          address=100.74.91.97
          port=${toString vncPort}
          enable_auth=true
          username=${user}
          password=$(<"$CREDENTIALS_DIRECTORY/password")
          rsa_private_key_file=$key
          certificate_file=$cert
          private_key_file=$tlsKey
          EOF
          exec ${vncResize} ${lib.getExe wayvnc} -L debug -C "$RUNTIME_DIRECTORY/config"
        '';
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
