{ config, pkgs, lib, home-manager, hyprland, ... }:

let
  homeDir = config.home.homeDirectory;
in {
  home.packages = with pkgs; [
    acpi
    bluetuith
    brillo
    dunst
    grim
    polkit-kde-agent
    libnotify
    pamix
    playerctl
    slurp
    swaybg
    swayidle
    swaylock-effects
    webcord # Discord client that works nicely with Hyprland
    wf-recorder
    wireplumber
    wl-clipboard
    xdg-desktop-portal-hyprland
  ];

  # Download wallpaper
  home.file.".wallpaper.png" = {
    source = builtins.fetchurl {
      url = "https://raw.githubusercontent.com/NixOS/nixos-artwork/ac04f06feb980e048b4ab2a7ca32997984b8b5ae/wallpapers/nix-wallpaper-dracula.png";
      sha256 = "sha256:07ly21bhs6cgfl7pv4xlqzdqm44h22frwfhdqyd4gkn2jla1waab";
    };
  };

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
        terminal = "${pkgs.wezterm}/bin/wezterm";
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

  # 1Password script
  home.file."bin/1password-toggle.sh" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # Check if hyprland 1password workspace exists
      # If not, create it
      hyprctl workspaces -j | grep -q 1password || killall -9 1password 2>/dev/null
      hyprctl workspaces -j | grep -q 1password || hyprctl dispatch exec "[workspace special:1password] 1password"
      # Toggle 1password workspace
      hyprctl dispatch togglespecialworkspace "1password"
    '';
  };

  # Nord-themed Swaylock
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      image = "${homeDir}/.wallpaper.png";
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
      exec-once = xprop -root -f _XWAYLAND_GLOBAL_OUTPUT_SCALE 32c -set _XWAYLAND_GLOBAL_OUTPUT_SCALE 2
      xwayland {
        force_zero_scaling = true
      }
      env = GDK_SCALE,2
      env = XCURSOR_SIZE,32

      general {
        col.active_border = 81a1c1ff
        no_border_on_floating = yes
        cursor_inactive_timeout = 3 # Hide mouse after 3 seconds of inactivity
        no_focus_fallback = true
        no_cursor_warps = true
      }

      # Apps to start on login
      exec-once = ${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland
      exec-once = [workspace special:1password] ${homeDir}/.nix-profile/bin/1password
      exec-once = ${pkgs.dunst}/bin/dunst
      exec-once = ${pkgs.polkit-kde-agent}/bin/polkit-kde-authentication-agent-1
      exec-once = ${pkgs.swaybg}/bin/swaybg -i ${homeDir}/.wallpaper.png
      ## Start wezterm in special workspace so I can toggle it
      exec-once = [workspace special:terminal] wezterm
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
      }

      ## Window rules
      windowrulev2 = dimaround, class:^(1Password)$, floating:1
      windowrule = rounding 10, ^(1Password)$
      windowrule = rounding 10, ^(firefox)$
      windowrulev2 = float, title:Spotify
      windowrulev2 = size 1800 1000, title:Spotify
      windowrulev2 = center, title:Spotify

      master {
        new_is_master = true # https://wiki.hyprland.org/Configuring/Master-Layout
      }

      ## Gestures
      gestures {
        workspace_swipe = on
      }

      input {
        float_switch_override_focus = 1
        touchpad {
          natural_scroll = yes
          disable_while_typing = true
        }
      }

      # General Keybindings
      $mainMod = SUPER
      ## Terminal
      bind = $mainMod, Return, exec, wezterm
      bind = CTRL_ALT, t, exec, wezterm
      bind = CTRL, grave, togglespecialworkspace, terminal
      ## 1Password
      bind = CTRL_SUPER, s, exec, ${homeDir}/bin/1password-toggle.sh
      ## Launcher
      bind = $mainMod, Space, exec, fuzzel
      ## Lock screen
      bind = $mainMod, l, exec, ${pkgs.swaylock-effects}/bin/swaylock
      ## Remap caps lock to super
      input {
        kb_options = caps:super
      }
      ## Audio
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

      ## Backlight
      bindle = , XF86MonBrightnessUp, exec, ${pkgs.brillo}/bin/brillo -A 5
      binde = , XF86MonBrightnessUp, exec, ${pkgs.libnotify}/bin/notify-send -e "Brightness: $(${pkgs.brillo}/bin/brillo)"
      bindle = , XF86MonBrightnessDown, exec, ${pkgs.brillo}/bin/brillo -U 5
      binde = , XF86MonBrightnessDown, exec, ${pkgs.libnotify}/bin/notify-send -e "Brightness: $(${pkgs.brillo}/bin/brillo)"

      ## Productivity
      bind = SUPER_SHIFT, s, exec, ${homeDir}/bin/screenshot.sh
      bind = CTRL_SHIFT, b, exec, ${homeDir}/bin/battpop.sh
      bind = CTRL_SHIFT, e, exec, hyprctl dispatch exit

      ## Navigation
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
    '';
    xwayland = {
      enable = true;
    };
  };
}
