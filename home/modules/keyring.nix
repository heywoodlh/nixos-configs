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
      if [ ! -t 0 ]; then
        echo "keyring-setup: no passphrase file and stdin is not a terminal" >&2
        exit 0
      fi
      passphrase=""
      read -rsp "Login keyring passphrase: " passphrase
      echo
      if [ -z "$passphrase" ]; then
        echo "keyring-setup: empty passphrase, not writing" >&2
        exit 1
      fi
      printf '%s' "$passphrase" > "$pass_file"
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
      description = "Prompt for the login keyring passphrase and unlock it at login.";
      type = types.bool;
    };
  };

  config = mkIf cfg.autoUnlock {
    home.packages = [keyringSetup];

    home.file.".config/autostart/unlock-keyring.desktop".text = ''
      [Desktop Entry]
      Name=Unlock keyring
      Comment=Unlock the login keyring at login
      Exec=${keyringSetup}/bin/keyring-setup
      Terminal=true
      Type=Application
      X-GNOME-Autostart-enabled=true
    '';

    wayland.windowManager.niri.settings._children =
      mkIf config.heywoodlh.home.niri.enable
      (mkAfter [
        {spawn-at-startup._args = ["${pkgs.foot}/bin/foot" "-e" "${keyringSetup}/bin/keyring-setup"];}
      ]);
  };
}
