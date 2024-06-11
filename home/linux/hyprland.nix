{ config, pkgs, lib, home-manager, hyprland, myFlakes, dark-wallpaper, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    acpi
    bluetuith
    bluez
    brillo
    dunst
    grim
    polkit-kde-agent
    libnotify
    pavucontrol
    playerctl
    procps
    pulseaudio
    slurp
    swaybg
    swayidle
    swaylock-effects
    util-linux
    wf-recorder
    wireplumber
    wl-clipboard
    xdg-desktop-portal-hyprland
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
        terminal = "${pkgs.gnome.gnome-terminal}/bin/gnome-terminal";
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
    ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | grep -Eo [0-9]+%)
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


  # 1Password script
  home.file."bin/1password-toggle.sh" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Check if 1password is running
      ps aux | grep -i 1password | grep -iq silent || ${homeDir}/.nix-profile/bin/1password --silent

      # Open 1password quick access
      ${homeDir}/.nix-profile/bin/1password --quick-access
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

  # Swayidle config
  services.swayidle = {
    enable = true;
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.systemd}/bin/loginctl lock-session";
      }
      {
        event = "lock";
        command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
      }
    ];
    timeouts = [
      {
        timeout = 330;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
  # start swayidle as part of hyprland, not sway
  systemd.user.services.swayidle.Install.WantedBy = lib.mkForce ["hyprland-session.target"];

  # Hyprland
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Fix blurry X11 apps, hidpi
      #exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 24c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      #xwayland {
      #  force_zero_scaling = true
      #}
      #env = GDK_SCALE, 2
      env = XCURSOR_SIZE, 24
      env = NIXOS_OZONE_WL, 1

      general {
        col.active_border = 81a1c1ff
        no_border_on_floating = yes
        no_focus_fallback = true
      }

      # Apps to start on login
      exec-once = ${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland
      exec-once = ${homeDir}/.nix-profile/bin/1password --silent
      exec-once = ${pkgs.dunst}/bin/dunst
      exec-once = ${pkgs.polkit-kde-agent}/bin/polkit-kde-authentication-agent-1
      exec-once = ${pkgs.swaybg}/bin/swaybg -i ${dark-wallpaper}
      # Start gnome-terminal in special workspace so I can toggle it
      #exec-once = [workspace special:terminal] ${pkgs.gnome.gnome-terminal}/bin/gnome-terminal
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

      # Window rules
      #windowrulev2 = dimaround, class:^(1Password)$, floating
      windowrulev2 = center, class:^(1Password)$
      windowrulev2 = stayfocused,class:^(1Password)$
      windowrule = rounding 10, ^(1Password)$
      windowrule = rounding 10, ^(firefox)$

      master {
        new_is_master = true # https://wiki.hyprland.org/Configuring/Master-Layout
      }

      # Gestures
      gestures {
        workspace_swipe = on
      }

      input {
        touchpad {
          natural_scroll = yes
          disable_while_typing = true
        }
      }

      # General Keybindings
      $mainMod = SUPER
      # Terminal
      bind = $mainMod, Return, exec, ${pkgs.gnome.gnome-terminal}/bin/gnome-terminal
      bind = CTRL_ALT, t, exec, ${pkgs.gnome.gnome-terminal}/bin/gnome-terminal
      bind = CTRL, grave, togglespecialworkspace, terminal
      # 1Password
      bind = CTRL_SUPER, s, exec, ${homeDir}/bin/1password-toggle.sh
      # Launcher
      bind = $mainMod, Space, exec, ${pkgs.fuzzel}/bin/fuzzel -I
      # Lock screen
      bind = $mainMod, l, exec, ${pkgs.swaylock-effects}/bin/swaylock
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
      bind = CTRL_SHIFT, f, exec, ${homeDir}/bin/applications.sh
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

      # Cursor
      cursor {
        inactive_timeout = 3
      }
    '';
    xwayland = {
      enable = true;
    };
  };
}
