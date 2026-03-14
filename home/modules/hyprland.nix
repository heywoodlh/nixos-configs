{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.heywoodlh.home.hyprland;
  onepasswordCfg = config.heywoodlh.home.onepassword;
  homeDir = config.home.homeDirectory;
  onepasswordToggle = pkgs.writeShellScriptBin "1password-toggle.sh" ''
    # Check if 1password is running
    ps aux | grep -i 1password | grep -iq silent || ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent --ozone-platform-hint=wayland

    # Open 1password quick access
    ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --quick-access
  '';
  lockCmdPfx = "" + optionalString (onepasswordCfg.enable) "${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --lock;";
  lockCmd = "${lockCmdPfx} ${pkgs.playerctl}/bin/playerctl --all-players pause; ${pkgs.swaylock-effects}/bin/swaylock -fF &";
  screenshotScript = pkgs.writeShellScriptBin "screenshot.sh" ''
    screenshot_path="${homeDir}/Downloads/screenshot.png"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - \
      | ${pkgs.coreutils}/bin/tee "$screenshot_path" \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  screenrecordScript = pkgs.writeShellScriptBin "screenrecord.sh" ''
    filename="${homeDir}/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    ${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp)" -t -f $filename
    [[ -e $filename ]] && ${pkgs.libnotify}/bin/notify-send "Screenrecord" "Saved to $filename"
  '';
  screenrecordKillScript = pkgs.writeShellScriptBin "screenrecord-kill.sh" ''
    killall -SIGINT wf-recorder
  '';
  battpopScript = pkgs.writeShellScriptBin "battpop.sh" ''
    ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | grep -Eo [0-9]+% | ${pkgs.coreutils}/bin/head -1)
  '';
  monitorsScript = pkgs.writeShellScriptBin "monitors.sh" ''
    # Hyprland
    # Script to select monitor and switch focus on it
    selection=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == false) | (.name + ": " + .description)' | ${pkgs.fuzzel}/bin/fuzzel -d | ${pkgs.coreutils}/bin/cut -d':' -f1)
    hyprctl dispatch focusmonitor $selection
    ${pkgs.libnotify}/bin/notify-send "Monitor switched to $selection"
  '';
  applicationsScript = pkgs.writeShellScriptBin "applications.sh" ''
    # Hyprland
    # Script to select open apps and switch focus to it
    # Excludes apps in special workspaces
    selection=$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.class != "") | select(.workspace.name | contains("special") | not) | (.class + ":" + .title + ":" + .address)' | ${pkgs.fuzzel}/bin/fuzzel -d --width=100 | ${pkgs.util-linux}/bin/rev | ${pkgs.coreutils}/bin/cut -d ':' -f1 | ${pkgs.util-linux}/bin/rev)

    hyprctl dispatch focuswindow address:$selection
  '';
  caffeineScript = pkgs.writeShellScriptBin "caffeine.sh" ''
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
  soundScript = pkgs.writeShellScriptBin "sound.sh" ''
    # This script is intended to make switching audio devices easier
    # Intended for PipeWire

    # Get current audio device info
    wpctl_status=$(wpctl status)
    audio_section=$(printf "$wpctl_status" | sed -n '/Audio/,/Streams/p')

    # Choose whether to set output (speaker) or input (microphone)
    selection=$(printf "Output\nInput" | fuzzel -d)

    if [[ $selection == "Output" ]]
    then
        sink_selection=$(printf "$audio_section" | sed -n '/Sinks/,/Sink endpoints/p' | grep -E '\.' | cut -d'[' -f1 | fuzzel --width=100 -d | head -1)
        sink_selection_name=$(printf "$sink_selection" | cut -d'.' -f2)
        sink_selection_id=$(printf "$sink_selection" | grep -o '[0-9]*')
        [[ -n $sink_selection_id ]] && wpctl set-default $sink_selection_id &&\
            notify-send "Set default audio input to$sink_selection_name"
    fi

    if [[ $selection == "Input" ]]
    then
        source_selection=$(printf "$audio_section" | sed -n '/Sources/,/Source endpoints/p' | grep -E '\.' | cut -d'[' -f1 | fuzzel --width=100 -d | head -1)
        source_selection_name=$(printf "$source_selection" | cut -d'.' -f2)
        source_selection_id=$(printf "$source_selection" | grep -o '[0-9]*')
        [[ -n $source_selection_id ]] && wpctl set-default $source_selection_id &&\
            notify-send "Set default audio output to$source_selection_name"
    fi
  '';
  keybindHelper = pkgs.writeShellScriptBin "keybind-helper.sh" ''
    HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
    # extract the keybindings from hyprland.conf
    # format: "MOD + KEY<TAB>description<TAB>command"
    mapfile -t BINDINGS < <(grep '^bind=' "$HYPR_CONF" | \
        sed -e 's/  */ /g' -e 's/bind=//g' -e 's/, /,/g' -e 's/ # /,/' | \
        awk -F, '{cmd=""; for(i=3;i<NF;i++) cmd=cmd $(i) " "; printf "%s + %s\t%s\t%s\n", $1, $2, $NF, cmd}')
    CHOICE=$(printf '%s\n' "''${BINDINGS[@]}" | fuzzel --dmenu --prompt="Hyprland Keybinds: ")
    # exit if no selection was made (e.g. user pressed ESC)
    [[ -z "$CHOICE" ]] && exit 0
    # extract cmd (3rd tab-separated field)
    CMD=$(echo "$CHOICE" | cut -f3 | sed 's/[[:space:]]*$//')
    # execute it if first word is exec else use hyprctl dispatch
    if [[ $CMD == exec* ]]; then
        eval "$CMD"
    else
        hyprctl dispatch "$CMD"
    fi
  '';
in {
  options = {
    heywoodlh.home.hyprland = mkOption {
      default = false;
      description = ''
        Enable heywoodlh hyprland configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    heywoodlh.home.onepassword.package = mkForce pkgs._1password-gui-beta;
    home.packages = with pkgs; [
      acpi
      adwaita-icon-theme
      bluetuith
      bluez
      brillo
      dunst
      grim
      hyprmon
      kdePackages.polkit-kde-agent-1
      libnotify
      nordic
      pavucontrol
      playerctl
      procps
      pulseaudio
      slurp
      swaybg
      swaylock-effects
      util-linux
      wf-recorder
      wireplumber
      wl-clipboard
      xdg-desktop-portal-hyprland
    ] ++ [
      screenshotScript
      screenrecordScript
      screenrecordKillScript
      battpopScript
      monitorsScript
      applicationsScript
      caffeineScript
      soundScript
      keybindHelper
    ] ++ optionals (config.heywoodlh.home.onepassword.enable) [
      onepasswordToggle
    ];

    # Dunst for notifications
    services.dunst.enable = true;

    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${pkgs.ghostty}/bin/ghostty";
          layer = "overlay";
          width = 50;
          lines = 5;
        };
      };
    };

    programs.ashell = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
      settings = {
        log_level = "warn";
        outputs = { Targets = [ "eDP-1" ]; };
        position = "Top";
        app_launcher_cmd = "${pkgs.fuzzel}/bin/fuzzel -I";

        modules = {
          left = [ [ "appLauncher" "Updates" "Workspaces" ] ];
          center = [ "WindowTitle" ];
          right = [ [ "Tray" "Clock" "Privacy" "Settings" ] ];
        };

        workspaces = {
          enable_workspace_filling = true;
        };

        CustomModule = [
          {
            name = "appLauncher";
            icon = "󱗼";
            command = "${pkgs.fuzzel}/bin/fuzzel -I";
          }
        ];

        window_title = {
          truncate_title_after_length = 100;
        };

        settings = {
          lock_cmd = "${lockCmd}";
          audio_sinks_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 3";
          audio_sources_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 4";
          wifi_more_cmd = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          vpn_more_cmd = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
          bluetooth_more_cmd = "${pkgs.blueberry}/bin/blueberry";
        };

        appearance = {
          style = "Islands";
        };
      };
    };

    # Workaround for ashell not starting immediately
    systemd.user.services.ashell = {
      Service = {
        Restart = mkForce "always";
        RestartSec = 5;
      };
    };

    xdg.desktopEntries = {
      screenrecord = {
        name = "Screenrecord";
        genericName = "recorder";
        comment = "Interactively record screen";
        exec = "${screenrecordScript}/bin/screenrecord.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
      screenrecord-kill = {
        name = "Screenrecord (Kill)";
        genericName = "recorder-kill";
        comment = "Kill recording screen";
        exec = "${screenrecordKillScript}/bin/screenrecord-kill.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
      monitor-switch = {
        name = "Monitor switch focus";
        genericName = "monitors";
        comment = "Switch monitor focus";
        exec = "${monitorsScript}/bin/monitors.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
      app-switcher = {
        name = "App Switcher";
        genericName = "applications";
        comment = "Switch application focus";
        exec = "${applicationsScript}/bin/applications.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
      caffeine = {
        name = "Caffeine toggle";
        genericName = "caffeine";
        comment = "Toggle caffeine";
        exec = "${caffeineScript}/bin/caffeine.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
      default-sound-switcher = {
        name = "Default Sound Device Switcher";
        genericName = "sound";
        comment = "Switch default sound device";
        exec = "${soundScript}/bin/sound.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
      keybind-helper = {
        name = "keybind-helper";
        genericName = "keybinds";
        comment = "Show Hyprland keybinds";
        exec = "${keybindHelper}/bin/keybind-helper.sh";
        terminal = false;
        type = "Application";
        categories = [ "Utility" ];
        icon = "nix-snowflake";
      };
    };

    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
    };

    # Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland; # use nixpkgs-provided hyprland
      extraConfig = ''
        # Fix blurry X11 apps, hidpi
        monitor=,preferred,auto,1
        env = XCURSOR_SIZE, 24

        general {
          no_focus_fallback = true
        }

        # Apps to start on login
        exec-once = ${pkgs.hyprland}/bin/hyprctl setcursor Adwaita 24
        exec-once = ${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland
        exec-once = ${pkgs.dunst}/bin/dunst
        exec-once = ${pkgs.kdePackages.polkit-kde-agent-1}/bin/polkit-kde-authentication-agent-1
        exec-once = ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets

        # DBUS
        exec-once = ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all

        # Dark mode for apps
        exec = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

        # Workarounds
        exec-once = /run/current-system/sw/bin/systemctl restart --user hypridle.service
        exec-once = /run/current-system/sw/bin/systemctl restart --user ashell.service
        exec-once = /run/current-system/sw/bin/systemctl restart --user hyprpaper.service
        exec-once = /run/current-system/sw/bin/systemctl restart --user kdeconnect.service

        # Start terminal in special workspace so I can toggle it
        #exec-once = [workspace special:terminal] ${pkgs.ghostty}/bin/ghostty
        workspace = special:terminal, on-created-empty:${pkgs.ghostty}/bin/ghostty --font-size=12
        # Animations
        animations {
          enabled = yes
          bezier = md3_standard, 0.2, 0.0, 0, 1.0
          bezier = md3_decel, 0.05, 0.7, 0.1, 1
          bezier = md3_accel, 0.3, 0, 0.8, 0.15
          bezier = overshot, 0.05, 0.9, 0.1, 1.05
          bezier = hyprnostretch, 0.05, 0.9, 0.1, 1.0
          bezier = win10, 0, 0, 0, 1
          bezier = gnome, 0, 0.85, 0.3, 1
          bezier = funky, 0.46, 0.35, -0.2, 1.2
          animation = windows, 1, 2, overshot, slide
          animation = border, 1, 10, default
          animation = fade, 1, 0.0000001, default
          animation = workspaces, 1, 4, md3_decel, slide
        }

        misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          #suppress_portal_warnings = true
        }

        ecosystem {
          no_update_news = true
          no_donation_nag = true
        }

        # 1Password Quick Access
        windowrule {
          name = 1password-quick-access
          match:title = ^(Quick Access — 1Password)$
          float = yes
          stay_focused = on
        }

        # Firefox PiP
        windowrule {
          name = firefox-pip
          move = ((monitor_w*0.72)) ((monitor_h*0.07))
          float = on
          opacity = 0.95 0.75
          pin = on
          keep_aspect_ratio = on
          match:title = ^(Picture-in-Picture)$
        }

        # Gestures
        gesture = 3, horizontal, workspace

        input {
          touchpad {
            natural_scroll = yes
            disable_while_typing = true
          }
        }

        # General Keybindings
        $mainMod = SUPER
        # Terminal
        bind = $mainMod, Return, exec, ${pkgs.ghostty}/bin/ghostty
        bind = CTRL_ALT, t, exec, ${pkgs.ghostty}/bin/ghostty
        bind = CTRL, grave, togglespecialworkspace, terminal
        # Emote picker
        bind = CTRL_SUPER, Space, exec, ${pkgs.emote}/bin/emote
        # Launcher
        bind = $mainMod, Space, exec, ${pkgs.fuzzel}/bin/fuzzel -I
        # Lock screen
        bind = $mainMod, l, exec, ${lockCmd}
        # Remap caps lock to super
        input {
          kb_options = caps:super
        }
        # Audio
        bindle =,XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        binde =,XF86AudioLowerVolume, exec, ${pkgs.libnotify}/bin/notify-send -t "1000" -e "Volume: $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)"
        bindle =,XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        binde =,XF86AudioRaiseVolume, exec, ${pkgs.libnotify}/bin/notify-send -t "1000" -e "Volume: $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)"
        bindle =,XF86AudioMute, exec, ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        binde =,XF86AudioMute, exec, ${pkgs.libnotify}/bin/notify-send -t "1000" -e "Volume: $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)"
        bind = CTRL_SHIFT, space, exec, ${pkgs.playerctl}/bin/playerctl play-pause
        bind = CTRL_SHIFT, space, exec, ${pkgs.libnotify}/bin/notify-send -e "Media: $(playerctl status)"
        bind = CTRL_SHIFT, n, exec, ${pkgs.playerctl}/bin/playerctl next
        bind = CTRL_SHIFT, n, exec, ${pkgs.libnotify}/bin/notify-send -e "Media: next track"
        bind = CTRL_SHIFT, p, exec, ${pkgs.playerctl}/bin/playerctl previous
        bind = CTRL_SHIFT, p, exec, ${pkgs.libnotify}/bin/notify-send -e "Media: previous track"

        # Backlight
        bindle = , XF86MonBrightnessUp, exec, ${pkgs.brillo}/bin/brillo -A 5
        binde = , XF86MonBrightnessUp, exec, ${pkgs.libnotify}/bin/notify-send -e "Brightness: $(${pkgs.brillo}/bin/brillo)"
        bindle = , XF86MonBrightnessDown, exec, ${pkgs.brillo}/bin/brillo -U 5
        binde = , XF86MonBrightnessDown, exec, ${pkgs.libnotify}/bin/notify-send -e "Brightness: $(${pkgs.brillo}/bin/brillo)"

        # Productivity
        bind = SUPER_SHIFT, s, exec, ${screenshotScript}/bin/screenshot.sh
        bind = CTRL_SHIFT, b, exec, ${battpopScript}/bin/battpop.sh
        bind = $mainMod, Tab, exec, ${applicationsScript}/bin/applications.sh
        bind = CTRL_SHIFT, e, exec, hyprctl dispatch exit
        bind = CTRL_SHIFT, b, exec, ${battpopScript}/bin/battpop.sh
        bind = CTRL_SHIFT, d, exec, ${pkgs.bash}/bin/bash -c '${pkgs.libnotify}/bin/notify-send $(date "+%T")'
        bind = CTRL_SUPER, h, exec, ${keybindHelper}/bin/keybind-helper.sh

        # Navigation
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 1, workspace, 2
        bind = $mainMod, 1, workspace, 3
        bind = $mainMod, 1, workspace, 4
        bind = CTRL_SHIFT, 1, movetoworkspace, 1
        bind = CTRL_SHIFT, 2, movetoworkspace, 2
        bind = CTRL_SHIFT, 3, movetoworkspace, 3
        bind = CTRL_SHIFT, 4, movetoworkspace, 4
        bind = $mainMod, bracketleft, workspace, r-1
        bind = $mainMod, bracketright, workspace, r+1
        bind = CTRL_SHIFT, bracketleft, focusmonitor, left
        bind = CTRL_SHIFT, bracketright, focusmonitor, right
        bind = CTRL_ALT, left, exec, ${pkgs.hyprland}/bin/hyprctl dispatch movewindow l
        bind = CTRL_ALT, right, exec, ${pkgs.hyprland}/bin/hyprctl dispatch movewindow r
        bind = CTRL_ALT, up, exec, ${pkgs.hyprland}/bin/hyprctl dispatch movewindow u
        bind = CTRL_ALT, down, exec, ${pkgs.hyprland}/bin/hyprctl dispatch movewindow d

        # Keyboard-driven mouse
        submap = cursor
        # Jump cursor to a position
        bind = ,a,exec,${pkgs.hyprland}/bin/hyprctl dispatch submap reset && ${pkgs.wl-kbptr}/bin/wl-kbptr && ${pkgs.hyprland}/bin/hyprctl dispatch submap cursor
        # Cursor movement
        binde = ,j,exec,${pkgs.wlrctl}/bin/wlrctl pointer move 0 10
        binde = ,k,exec,${pkgs.wlrctl}/bin/wlrctl pointer move 0 -10
        binde = ,l,exec,${pkgs.wlrctl}/bin/wlrctl pointer move 10 0
        binde = ,h,exec,${pkgs.wlrctl}/bin/wlrctl pointer move -10 0
        # Left button
        binde = ,s,exec,${pkgs.wlrctl}/bin/wlrctl pointer click left
        binde = ,y,exec,${pkgs.wlrctl}/bin/wlrctl pointer click left
        # Middle button
        binde = ,d,exec,${pkgs.wlrctl}/bin/wlrctl pointer click middle
        # Right button
        binde = ,f,exec,${pkgs.wlrctl}/bin/wlrctl pointer click right
        binde = ,u,exec,${pkgs.wlrctl}/bin/wlrctl pointer click right
        # Scroll up and down
        binde = ,e,exec,${pkgs.wlrctl}/bin/wlrctl pointer scroll 10 0
        binde = ,r,exec,${pkgs.wlrctl}/bin/wlrctl pointer scroll -10 0
        # Scroll left and right
        binde = ,t,exec,${pkgs.wlrctl}/bin/wlrctl pointer scroll 0 -10
        binde = ,g,exec,${pkgs.wlrctl}/bin/wlrctl pointer scroll 0 10
        # Exit cursor submap
        # If you do not use cursor timeout or cursor:hide_on_key_press, you can delete its respective calls.
        bind = ,escape,exec,${pkgs.hyprland}/bin/hyprctl keyword cursor:inactive_timeout 3; ${pkgs.hyprland}/bin/hyprctl keyword cursor:hide_on_key_press true; ${pkgs.hyprland}/bin/hyprctl dispatch submap reset 
        submap  =  reset
        # Entrypoint
        # If you do not use cursor timeout or cursor:hide_on_key_press, you can delete its respective calls.
        bind = $mainMod,g,exec,${pkgs.hyprland}/bin/hyprctl keyword cursor:inactive_timeout 0; ${pkgs.hyprland}/bin/hyprctl keyword cursor:hide_on_key_press false; ${pkgs.hyprland}/bin/hyprctl dispatch submap cursor

        # Cursor
        cursor {
          inactive_timeout = 3
        }
      '' + optionalString (config.heywoodlh.home.onepassword.enable) ''
        exec-once = ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent
        bind = CTRL_SUPER, s, exec, ${onepasswordToggle}/bin/1password-toggle.sh
      '' + optionalString (config.heywoodlh.home.librewolf.enable) ''
        exec-once = ${pkgs.xdg-utils}/bin/xdg-settings set default-web-browser librewolf.desktop
      '';
      xwayland = {
        enable = true;
      };
    };

    # Wallpaper daemon
    services.hyprpaper.enable = true;

    # KDE Connect
    services.kdeconnect.enable = true;

    # Idle/suspend daemon
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "${lockCmd}";
          before_sleep_cmd = "${lockCmd}";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "${lockCmd}";
          }
          {
            timeout = 1200;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl dispatch dpms off";
            on-resume = "${pkgs.hyprland}/bin/hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
