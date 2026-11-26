{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.heywoodlh.home.keyring;
  keyringSetup = pkgs.writeShellScriptBin "keyring-setup" ''
    set -euo pipefail
    uid="$(${pkgs.coreutils}/bin/id -u)"
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$uid}"
    export DBUS_SESSION_BUS_ADDRESS="''${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

    pass_dir="$HOME/.config/keyring"
    pass_file="$pass_dir/password.txt"
    login_keyring="$HOME/.local/share/keyrings/login.keyring"
    first_run=false

    ${pkgs.coreutils}/bin/mkdir -p "$pass_dir"
    ${pkgs.coreutils}/bin/chmod 700 "$pass_dir"

    if [ ! -s "$pass_file" ]; then
      first_run=true
      umask 077
      ${pkgs.openssl}/bin/openssl rand -base64 32 | ${pkgs.coreutils}/bin/tr -d '\n' > "$pass_file"
    fi
    ${pkgs.coreutils}/bin/chmod 600 "$pass_file"

    if [ "$first_run" = true ] && [ -f "$login_keyring" ]; then
      backup="$login_keyring.pre-keyring-setup.$(${pkgs.coreutils}/bin/date +%s)"
      ${pkgs.coreutils}/bin/mv "$login_keyring" "$backup"
      echo "keyring-setup: backed up existing login keyring to $backup"
      ${pkgs.procps}/bin/pkill -u "$uid" -f gnome-keyring-daemon || true
      for _ in $(${pkgs.coreutils}/bin/seq 1 20); do
        ${pkgs.procps}/bin/pgrep -u "$uid" -f gnome-keyring-daemon >/dev/null || break
        ${pkgs.coreutils}/bin/sleep 0.1
      done
    fi

    ${pkgs.coreutils}/bin/timeout 15 ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --unlock < "$pass_file" >/dev/null || true
  '';
in {
  options.heywoodlh.home.keyring = {
    autoUnlock = mkOption {
      default = false;
      description = "Set up the login keyring with a generated passphrase and unlock it at login.";
      type = types.bool;
    };
  };

  config = mkIf cfg.autoUnlock {
    systemd.user.services.keyring-setup = {
      Unit = {
        Description = "Set up and unlock the login keyring";
        After = ["basic.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${keyringSetup}/bin/keyring-setup";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install.WantedBy = ["default.target"];
    };
  };
}
