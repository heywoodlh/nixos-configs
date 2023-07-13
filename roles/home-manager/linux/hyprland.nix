{ config, pkgs, lib, home-manager, hyprland, ... }:

{
  home.packages = with pkgs; [
    acpi
    bluetuith
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
      filename="/home/heywoodlh/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
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
      Exec=/home/heywoodlh/bin/screenrecord.sh
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
      Exec=/home/heywoodlh/bin/screenrecord-kill.sh
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

  # Swaylock
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      image = "/home/heywoodlh/.wallpaper.png";
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
      exec-once = [workspace special:1password] /home/heywoodlh/.nix-profile/bin/1password
      exec-once = ${pkgs.dunst}/bin/dunst
      exec-once = ${pkgs.polkit-kde-agent}/bin/polkit-kde-authentication-agent-1
      exec-once = ${pkgs.swaybg}/bin/swaybg -i /home/heywoodlh/.wallpaper.png
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
      bind = CTRL_SUPER, s, exec, /home/heywoodlh/bin/1password-toggle.sh
      ## Launcher
      bind = $mainMod, Space, exec, fuzzel
      ## Lock screen
      bind = $mainMod, l, exec, ${pkgs.swaylock-effects}/bin/swaylock
      ## Remap caps lock to super
      input {
        kb_options = caps:super
      }
      ## Media keys
      binde =,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
      binde =,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
      bind =,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind = SUPER_SHIFT, s, exec, /home/heywoodlh/bin/screenshot.sh
      bind = CTRL_SHIFT, b, exec, /home/heywoodlh/bin/battpop.sh
      bind = CTRL_SHIFT, e, exec, hyprctl dispatch exit
      bind = CTRL_SHIFT, space, exec, ${pkgs.playerctl}/bin/playerctl play-pause
      bind = CTRL_SHIFT, n, exec, ${pkgs.playerctl}/bin/playerctl next
      bind = CTRL_SHIFT, p, exec, ${pkgs.playerctl}/bin/playerctl previous

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
