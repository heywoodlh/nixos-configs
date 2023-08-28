{ config, pkgs, lib, jovian-nixos, home-manager, ... }:

{
  imports = [
    (jovian-nixos + "/modules")
    home-manager.nixosModule
  ];

  jovian = {
    steam.enable = true;
    devices.steamdeck = {
      enable = true;
    };
  };

  services.xserver.displayManager.gdm.wayland = lib.mkForce true; # lib.mkForce is only required on my setup because I'm using some other NixOS configs that conflict with this value
  services.xserver.displayManager.defaultSession = "steam-wayland";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "heywoodlh";

  # Enable GNOME
  sound.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

  # Create user
  users.users.heywoodlh = {
    isNormalUser = true;
    description = "Spencer Heywood";
  };

  systemd.services.gamescope-switcher = {
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      User = 1000;
      PAMName = "login";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";

      Restart = "always";
    };

    script = ''
      set-session () {
        mkdir -p ~/.local/state
        >~/.local/state/steamos-session-select echo "$1"
      }
      consume-session () {
        if [[ -e ~/.local/state/steamos-session-select ]]; then
          cat ~/.local/state/steamos-session-select
          rm ~/.local/state/steamos-session-select
        else
          echo "gamescope"
        fi
      }
      while :; do
        session=$(consume-session)
        case "$session" in
          plasma)
            dbus-run-session -- gnome-shell --display-server --wayland
            ;;
          gamescope)
            steam-session
            ;;
        esac
      done
    '';
  };

  environment.systemPackages = with pkgs; [
    gnome.gnome-terminal
    gnomeExtensions.dash-to-dock
    jupiter-dock-updater-bin
    steamdeck-firmware
  ];

  # GNOME settings through home-manager
  home-manager.users.heywoodlh = {
    dconf.settings = {
      # Enable on-screen keyboard
      "org/gnome/desktop/a11y/applications" = {
        screen-keyboard-enabled = true;
      };
      "org/gnome/shell" = {
        enabled-extensions = [
          "dash-to-dock@micxgx.gmail.com"
        ];
        favorite-apps = ["steam.desktop"];
      };
      # Dash to Dock settings for a better touch screen experience
      "org/gnome/shell/extensions/dash-to-dock" = {
        background-opacity = 0.80000000000000004;
        custom-theme-shrink = true;
        dash-max-icon-size = 48;
        dock-fixed = true;
        dock-position = "LEFT";
        extend-height = true;
        height-fraction = 0.60999999999999999;
        hot-keys = false;
        preferred-monitor = -2;
        preferred-monitor-by-connector = "eDP-1";
        scroll-to-focused-application = true;
        show-apps-at-top = true;
        show-mounts = true;
        show-show-apps-button = true;
        show-trash = false;
      };
    };
  };
}
