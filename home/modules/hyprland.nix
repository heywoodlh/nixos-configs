{
  config,
  pkgs,
  lib,
  dark-wallpaper,
  ...
}:

with lib;

let
  cfg = config.heywoodlh.home.hyprland;
  onepasswordCfg = config.heywoodlh.home.onepassword;
  system = pkgs.stdenv.hostPlatform.system;
  homeDir = config.home.homeDirectory;
  ashellConf = pkgs.writeText "config.toml" ''
    log_level = "warn"
    outputs = { Targets = ["eDP-1"] }
    position = "Top"
    app_launcher_cmd = "${pkgs.fuzzel}/bin/fuzzel -I"

    [modules]
    left = [ [ "appLauncher", "Updates", "Workspaces" ] ]
    center = [ "WindowTitle" ]
    right = [ [  "Tray", "Clock", "Privacy", "Settings" ] ]

    [workspaces]
    enable_workspace_filling = true

    [[CustomModule]]
    name = "appLauncher"
    icon = "󱗼"
    command = "${pkgs.fuzzel}/bin/fuzzel -I"

    [window_title]
    truncate_title_after_length = 100

    [settings]
    lock_cmd = "${lockCmd}"
    audio_sinks_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 3"
    audio_sources_more_cmd = "${pkgs.pavucontrol}/bin/pavucontrol -t 4"
    wifi_more_cmd = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor"
    vpn_more_cmd = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor"
    bluetooth_more_cmd = "${pkgs.blueberry}/bin/blueberry"

    [appearance]
    style = "Islands"
    primary_color = "#8cc4ff"
    success_color = "#56b3da"
    text_color = "#d6deeb"

    workspace_colors = [ "#8cc4ff", "#56b3da" ]

    special_workspace_colors = [ "#8cc4ff", "#56b3da" ]

    [appearance.danger_color]
    base = "#eb9e0f"
    weak = "#d99a6f"

    [appearance.background_color]
    base = "#2c323a"
    weak = "#3b4257"
    strong = "#47535e"

    [appearance.secondary_color]
    base = "#3b5b6c"
  '';
  onepasswordToggle = pkgs.writeShellScriptBin "1password-toggle.sh" ''
    # Check if 1password is running
    ps aux | grep -i 1password | grep -iq silent || ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent --ozone-platform-hint=wayland

    # Open 1password quick access
    ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --quick-access
  '';
  lockCmdPfx = "" + optionalString (onepasswordCfg.enable) "${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --lock;";
  lockCmd = "${lockCmdPfx} ${pkgs.playerctl}/bin/playerctl --all-players pause; ${pkgs.swaylock-effects}/bin/swaylock -fF &";
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
    ] ++ optionals (config.heywoodlh.home.onepassword.enable) [
      onepasswordToggle
    ];

    # Dunst config
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

    # Fuzzel launcher Nord theme
    programs.fuzzel = {
      enable = true;
      settings = {
        main = {
          terminal = "${pkgs.ghostty}/bin/ghostty";
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

    programs.ashell = {
      enable = true;
      systemd = {
        enable = true;
        target = "graphical-session.target";
      };
    };

    # Workaround for ashell not starting immediately
    systemd.user.services.ashell = {
      Service = {
        Restart = mkForce "always";
        RestartSec = 5;
      };
    };

    home.file.".config/ashell/config.toml" = {
      enable = true;
      source = ashellConf;
    };

    # Screenshot scripts
    home.file."bin/screenshot.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
    };

    # Screenrecord scripts
    home.file."bin/screenrecord.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        filename="${homeDir}/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
        ${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp)" -t -f $filename
        [[ -e $filename ]] && ${pkgs.libnotify}/bin/notify-send "Screenrecord" "Saved to $filename"
      '';
    };

    # Screenrecord scripts
    home.file."bin/screenrecord-kill.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        killall -SIGINT wf-recorder
      '';
    };

    # Screen record desktop file
    home.file.".local/share/applications/screenrecord.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Screenrecord
        GenericName=recorder
        Comment=Interactively record screen
        Exec=${homeDir}/bin/screenrecord.sh
        Terminal=false
        Type=Application
        Keywords=recorder;screen;record;video;hyprland
        Icon=nix-snowflake
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
        Exec=${homeDir}/bin/screenrecord-kill.sh
        Terminal=false
        Type=Application
        Keywords=recorder;screen;record;video;hyprland
        Icon=nix-snowflake
        Categories=Utility;
      '';
    };

    # Battery notification script
    home.file."bin/battpop.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | grep -Eo [0-9]+% | ${pkgs.coreutils}/bin/head -1)
      '';
    };

    # Monitor switching script
    home.file."bin/monitors.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Hyprland
        # Script to select monitor and switch focus on it
        selection=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == false) | (.name + ": " + .description)' | ${pkgs.fuzzel}/bin/fuzzel -d | ${pkgs.coreutils}/bin/cut -d':' -f1)
        hyprctl dispatch focusmonitor $selection
        ${pkgs.libnotify}/bin/notify-send "Monitor switched to $selection"
      '';
    };

    # Monitor switch
    home.file.".local/share/applications/monitor-switch.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Monitor switch focus
        GenericName=monitors
        Comment=Switch monitor focus
        Exec=${homeDir}/bin/monitors.sh
        Terminal=false
        Type=Application
        Keywords=hyprland;monitor
        Icon=nix-snowflake
        Categories=Utility;
      '';
    };

    # Application switching script
    home.file."bin/applications.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Hyprland
        # Script to select open apps and switch focus to it
        # Excludes apps in special workspaces
        selection=$(hyprctl clients -j | ${pkgs.jq}/bin/jq -r '.[] | select(.class != "") | select(.workspace.name | contains("special") | not) | (.class + ":" + .title + ":" + .address)' | ${pkgs.fuzzel}/bin/fuzzel -d --width=100 | ${pkgs.util-linux}/bin/rev | ${pkgs.coreutils}/bin/cut -d ':' -f1 | ${pkgs.util-linux}/bin/rev)

        hyprctl dispatch focuswindow address:$selection
      '';
    };

    # App switcher
    home.file.".local/share/applications/app-switcher.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=App Switcher
        GenericName=applications
        Comment=Switch application focus
        Exec=${homeDir}/bin/applications.sh
        Terminal=false
        Type=Application
        Keywords=hyprland;monitor
        Icon=nix-snowflake
        Categories=Utility;
      '';
    };

    # Caffeine toggle script
    home.file."bin/caffeine.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash
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
    };

    # Caffeine toggler
    home.file.".local/share/applications/caffeine.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Caffeine toggle
        GenericName=caffeine
        Comment=Toggle caffeine
        Exec=${homeDir}/bin/caffeine.sh
        Terminal=false
        Type=Application
        Keywords=hyprland;monitor;caffeine;suspend
        Icon=nix-snowflake
        Categories=Utility;
      '';
    };

    # Default sound device switching script
    home.file."bin/sound.sh" = {
      enable = true;
      executable = true;
      text = ''
        #!/usr/bin/env bash

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
    };

    # Default sound switcher
    home.file.".local/share/applications/default-sound-switcher.desktop" = {
      enable = true;
      text = ''
        [Desktop Entry]
        Name=Default Sound Device Switcher
        GenericName=sound
        Comment=Switch default sound device
        Exec=${homeDir}/bin/sound.sh
        Terminal=false
        Type=Application
        Keywords=hyprland;audio
        Icon=nix-snowflake
        Categories=Utility;
      '';
    };

    # Nord-themed Swaylock
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock-effects;
      settings = {
        image = "${dark-wallpaper}";
        bs-hl-color = "b48eadff";
        caps-lock-bs-hl-color = "d08770ff";
        caps-lock-key-hl-color = "ebcb8bff";
        font = "JetBrainsMono Nerd Font Mono";
        indicator-radius = "25";
        indicator-thickness = "10";
        inside-color = "2e3440ff";
        inside-clear-color = "81a1c1ff";
        inside-ver-color = "5e81acff";
        inside-wrong-color = "bf616aff";
        key-hl-color = "a3be8cff";
        layout-bg-color = "2e3440ff";
        line-uses-ring = true;
        ring-color = "3b4252ff";
        ring-clear-color = "88c0d0ff";
        ring-ver-color = "81a1c1ff";
        ring-wrong-color = "d08770ff";
        separator-color = "3b4252ff";
        text-color = "eceff4ff";
        text-clear-color = "3b4252ff";
        text-ver-color = "3b4252ff";
        text-wrong-color = "3b4252ff";
      };
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
        exec-once = ${pkgs.swaybg}/bin/swaybg -i ${dark-wallpaper}
        exec-once = ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets

        # Dark mode for apps
        exec = gsettings set org.gnome.desktop.interface gtk-theme "Nordic-darker"   # for GTK3 apps
        exec = gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

        # Workaround for hypridle
        exec-once = /run/current-system/sw/bin/systemctl restart --user hypridle.service
        exec-once = /run/current-system/sw/bin/systemctl restart --user ashell.service

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

        # Window rules
        windowrulev2 = float,class:(1password)
        windowrulev2 = nomaxsize,class:(1password)
        windowrulev2 = float,title:^(Quick Access — 1Password)$
        windowrulev2 = nomaxsize,title:^(Quick Access — 1Password)$

        # Firefox PiP
        windowrulev2 = float, title:^(Picture-in-Picture)$
        windowrulev2 = size 20% 20%, title:^(Picture-in-Picture)$
        windowrulev2 = move 100%-w-30, title:^(Picture-in-Picture)$
        windowrulev2 = pin, title:^(Picture-in-Picture)$
        windowrulev2 = noborder, title:^(Picture-in-Picture)$

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
        bind = SUPER_SHIFT, s, exec, ${homeDir}/bin/screenshot.sh
        bind = CTRL_SHIFT, b, exec, ${homeDir}/bin/battpop.sh
        bind = SUPER_TAB, f, exec, ${homeDir}/bin/applications.sh
        bind = CTRL_SHIFT, e, exec, hyprctl dispatch exit
        bind = CTRL_SHIFT, b, exec, ${homeDir}/bin/battpop.sh
        bind = CTRL_SHIFT, d, exec, ${pkgs.bash}/bin/bash -c '${pkgs.libnotify}/bin/notify-send $(date "+%T")'

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
