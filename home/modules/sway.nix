{ config, lib, pkgs, nixpkgs-stable, dark-wallpaper, ... }:

with lib;

# Some credit to helpful sources:
# https://github.com/lokesh-krishna/dotfiles/blob/8a90f5c1f72ffacf7fc1641ba7c72c4aaac76246/nord-v3
# https://github.com/gytis-ivaskevicius/nixfiles/blob/4a6dc53cb1eae075d7303ce2b90e02ad850b48fb/home-manager/sway.nix
# https://github.com/hex46/dotfiles-Nordic-Sway/tree/cf766491bb3fccb11760aba3802f5930fc50f07e

let
  cfg = config.heywoodlh.home.sway;
  system = pkgs.stdenv.hostPlatform.system;
  snowflake = ../../assets/nixos-snowflake.png;
  pkgs-stable = nixpkgs-stable.legacyPackages.${system};
  homeDir = config.home.homeDirectory;
  # Screenshot scripts
  screenshot = pkgs.writeShellScriptBin "screenshot.sh" ''
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  # Screenrecord scripts
  screenrecord = pkgs.writeShellScriptBin "screenrecord.sh" ''
    filename="${homeDir}/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    ${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp)" -t -f $filename
    [[ -e $filename ]] && ${pkgs.libnotify}/bin/notify-send "Screenrecord" "Saved to $filename"
  '';
  # Screenrecord scripts
  screenrecord-kill = pkgs.writeShellScriptBin "screenrecord-kill.sh" ''
    killall -SIGINT wf-recorder
  '';
  # Battery notification script
  battpop = pkgs.writeShellScriptBin "battpop.sh" ''
    ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | grep -Eo [0-9]+%)
  '';

  caffeine = pkgs.writeShellScriptBin "caffeine.sh" ''
    export caffeine_enabled="false"
    ${pkgs.procps}/bin/ps aux | ${pkgs.gnugrep}/bin/grep -i systemd-inhibit | ${pkgs.gnugrep}/bin/grep -iq caffeine && caffeine_enabled="true"

    if [[ "$caffeine_enabled" == "true" ]]
    then
        ${pkgs.procps}/bin/pkill -9 systemd-inhibit && ${pkgs.libnotify}/bin/notify-send "Disabled caffeine"
    else
        ${pkgs.systemd}/bin/systemd-inhibit --what=idle --who=Caffeine --why=Caffeine --mode=block sleep inf &
        disown
        ${pkgs.libnotify}/bin/notify-send "Enabled caffeine"
    fi
  '';
in {
  options = {
    heywoodlh.home.sway = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh Sway configuration.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    # XDG portal
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
      config.sway.default = "wlr";
    };

    # Fuzzel launcher Nord theme
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${pkgs.gnome-terminal}/bin/gnome-terminal";
          layer = "overlay";
          width = 45;
          lines = 5;
        };
        colors = {
          background = "3b4252ff";
          text = "f8f8f2ff";
          match = "8be9fdff";
          selection-match = "8be9fdff";
          selection = "739dd1ff";
          selection-text = "ffffffff";
          border = "81a1c1ff";
        };
      };
    };

    services.dunst = {
      enable = true;
      settings = {
        global = {
          frame_color = "#e5e9f0";
          separator_color = "#e5e9f0";
        };
        base16_low = {
          msg_urgency = "low";
          background = "#3b4252";
          foreground = "#4c566a";
        };
        base16_normal = {
          msg_urgency = "normal";
          background = "#434c5e";
          foreground = "#e5e9f0";
        };
        base16_critical = {
          msg_urgency = "critical";
          background = "#bf616a";
          foreground = "#eceff4";
        };
      };
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      MOZ_USE_XINPUT2 = "1";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "sway";
      XKB_DEFAULT_OPTIONS = "terminate:ctrl_alt_bksp,caps:escape,altwin:swap_alt_win";
      SDL_VIDEODRIVER = "wayland";

      # needs qt5.qtwayland in systemPackages
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      _JAVA_AWT_WM_NONREPARENTING = 1;

      # gtk applications on wayland
      # export GDK_BACKEND=wayland
    };

    wayland.windowManager.sway = {
      enable = true;
      config = {};
      config.bars = [{
        "command" = "${pkgs.waybar}/bin/waybar";
      }];
      extraConfig = ''
        exec ${pkgs.polkit-kde-agent}/bin/polkit-kde-authentication-agent-1

        # Super key
        set $mod Mod4

        # Gaps & border
        gaps inner 8
        default_border pixel 2
        for_window [title=".*"] border pixel 2

        # XDG desktop fix
        exec ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

        exec ${pkgs.swayidle}/bin/swayidle -w \
          timeout 300 '${pkgs.swaylock-fancy}/bin/swaylock-fancy -f' \
          timeout 305 '${pkgs.sway}/bin/swaymsg "output * power off"' \
          resume '${pkgs.sway}/bin/swaymsg "output * power on"'

        # Wallpaper
        output * bg ${dark-wallpaper} fill

        # Reload the configuration file
        bindsym $mod+Shift+r reload
        bindsym $mod+Shift+e exec loginctl terminate-user $USER

        # Launcher
        set $menu ${pkgs.fuzzel}/bin/fuzzel -I
        bindsym $mod+space exec $menu

        # Terminal
        set $term ${pkgs.gnome-terminal}/bin/gnome-terminal
        bindsym $mod+Return exec $term
        bindsym ctrl+alt+t exec $term

        # Screenshot
        bindsym $mod+shift+s exec ${screenrecord}/bin/screenrecord.sh

        # Battpop
        bindsym $mod+shift+b exec ${battpop}/bin/battpop.sh

        ## Special keys
        bindsym --locked XF86AudioRaiseVolume exec sh -c "${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 false ; ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 +5%"
        bindsym --locked XF86AudioLowerVolume exec sh -c "${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 false ; ${pkgs.pulseaudio}/bin/pactl set-sink-volume 0 -5%"
        bindsym --locked XF86AudioMute exec ${pkgs.pulseaudio}/bin/pactl set-sink-mute 0 toggle
        bindsym XF86MonBrightnessUp exec ${pkgs.light}/bin/light -A 10 && ${pkgs.libnotify}/bin/notify-send "󰃞 Light" "Brightness: $(light)%"
        bindsym XF86MonBrightnessDown exec ${pkgs.light}/bin/light -U 10 && ${pkgs.libnotify}/bin/notify-send "󰃞 Light" "Brightness: $(light)%"
        bindsym --locked XF86AudioPlay exec ${pkgs.mpc-cli}/bin/mpc toggle
        bindsym --locked XF86AudioNext exec ${pkgs.mpc-cli}/bin/mpc next
        bindsym --locked XF86AudioPrev exec ${pkgs.mpc-cli}/bin/mpc prev

        bindsym $mod+0 workspace number 10
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+6 workspace number 6
        bindsym $mod+7 workspace number 7
        bindsym $mod+8 workspace number 8
        bindsym $mod+9 workspace number 9

        bindsym $mod+bracketright workspace next_on_output
        bindsym $mod+bracketleft workspace prev_on_output

        bindsym ctrl+grave exec ${pkgs-stable.guake}/bin/guake
      '';
    };

    home.packages = with pkgs; [
      gnome-terminal
      screenrecord
      screenrecord-kill
      screenshot
      battpop
      wl-clipboard
      wofi
    ];

    # Screen record desktop file
    home.file.".local/share/applications/screenrecord.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Screenrecord
        GenericName=recorder
        Comment=Interactively record screen
        Exec=${screenrecord}/bin/screenrecord.sh
        Terminal=false
        Type=Application
        Keywords=recorder;screen;record;video
        Icon=${snowflake}
        Categories=Utility;
      '';
    };

    # Screen record killer desktop file
    home.file.".local/share/applications/screenrecord-kill.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Screenrecord (Kill)
        GenericName=recorder-kill
        Comment=Kill recording screen
        Exec=${screenrecord-kill}/bin/screenrecord-kill.sh
        Terminal=false
        Type=Application
        Keywords=recorder;screen;record;video
        Icon=${snowflake}
        Categories=Utility;
      '';
    };

    home.file.".local/share/applications/caffeine.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Toggle Caffeine
        GenericName=caffeine
        Exec=${caffeine}/bin/caffeine.sh
        Terminal=false
        Type=Application
        Keywords=caffeine;awake;sleep
        Icon=${snowflake}
        Categories=Utility;
      '';
    };

    programs.waybar = {
      enable = true;
      settings = [{
        layer = "top";
        position = "top";
        modules-left = [ "sway/workspaces" ];
        modules-center = [ "sway/window" ];
        modules-right = [ "pulseaudio" "cpu" "memory" "temperature" "clock" "tray" ];
        clock.format = "{:%Y-%m-%d %H:%M}";
        "tray" = { spacing = 8; };
        "cpu" = { format = "cpu {usage}"; };
        "memory" = { format = "mem {}"; };
        "temperature" = {
          hwmon-path = "/sys/class/hwmon/hwmon1/temp2_input";
          format = "tmp {temperatureC}C";
        };
        "pulseaudio" = {
          format = "vol {volume} {format_source}";
          format-bluetooth = "volb {volume} {format_source}";
          format-bluetooth-muted = "volb {format_source}";
          format-muted = "vol {format_source}";
          format-source = "mic {volume}";
          format-source-muted = "mic";
        };
      }];
      style = ''
        /*
        *   Nord theme
        *   src : https://www.nordtheme.com/docs/colors-and-palettes
        */
        /* Polar Night */
        @define-color nord0 #2e3440;
        @define-color nord1 #3b4252;
        @define-color nord2 #434c5e;
        @define-color nord3 #4c566a;
        /* Snow storm */
        @define-color nord4 #d8dee9;
        @define-color nord5 #e5e9f0;
        @define-color nord6 #eceff4;
        /* Frost */
        @define-color nord7 #8fbcbb;
        @define-color nord8 #88c0d0;
        @define-color nord9 #81a1c1;
        @define-color nord10 #5e81ac;
        /* Aurora */
        @define-color nord11 #bf616a;
        @define-color nord12 #d08770;
        @define-color nord13 #ebcb8b;
        @define-color nord14 #a3be8c;
        @define-color nord15 #b48ead;

        window {
            background-color: transparent;
        }

        * {
            font-family: JetBrains Mono;
            font-size: 14px;
            font-weight: 600;
            margin-top: 2px;
        }

        /*
        * Left part
        */
        #mode {
            color: @nord0;
            background-color: @nord13;
            margin-left: 8px;
            border-radius: 5px;
            padding: 0px 6px;
        }

        #workspaces button {
            margin-left: 8px;
            background-color: @nord3;
            padding: 0px 4px;
            color: @nord6;
            margin-top: 0;
        }

        #workspaces button.focused {
            color: @nord0;
            background-color: @nord8;
        }

        #window {
            margin-left: 10px;
            color: @nord6;
            font-weight: bold;
            padding: 0px 5px;
        }

        /*
        * Right part
        */
        #pulseaudio,
        #network,
        #cpu,
        #memory,
        #backlight,
        #language,
        #battery,
        #clock,
        #tray {
            background-color: @nord2;
            padding: 0px 8px;
            color: @nord6;
        }

        #backlight,
        #language,
        #battery,
        #clock,
        #tray {
            margin-right: 8px;
            border-top-right-radius: 5px;
            border-bottom-right-radius: 5px;
        }

        #pulseaudio,
        #network,
        #clock,
        #tray {
            border-top-left-radius: 5px;
            border-bottom-left-radius: 5px;
        }

        #pulseaudio.muted {
            background-color: @nord13;
            color: @nord3;
        }

        #pulseaudio, #backlight {
            background-color: @nord10;
        }

        #network, #cpu, #memory, #battery {
            background-color: @nord3;
        }

        #tray {
            background-color: @nord1;
        }

        #network.disabled,
        #network.disconnected {
            background-color: @nord13;
            color: @nord0;
        }

        #battery.warning {
            background-color: @nord13;
            color: @nord0;
        }

        #battery.critical {
            background-color: @nord11;
            color: @nord0;
        }

        #tray menu {
            background-color: @nord2;
            color: @nord4;
            padding: 10px 5px;
            border: 2px solid @nord1;
        }
      '';
    };
  };
}
