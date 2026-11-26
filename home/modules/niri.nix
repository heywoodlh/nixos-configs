{
  config,
  pkgs,
  nixpkgs-stable,
  lib,
  ...
}:
with lib; let
  cfg = config.heywoodlh.home.niri;
  pkgs-stable = import nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };
  niri = "${config.wayland.windowManager.niri.package}/bin/niri";
  onepasswordCfg = config.heywoodlh.home.onepassword;
  homeDir = config.home.homeDirectory;
  noctaliaBin = "${config.programs.noctalia.package}/bin/noctalia";
  noctaliaMsg = "${noctaliaBin} msg";
  dmenu = "${noctaliaBin} dmenu";
  lockCmd = "${noctaliaMsg} session lock";
  onepasswordToggle = pkgs.writeShellScriptBin "1password-toggle.sh" ''
    ps aux | grep -i "1password" | grep -iq silent || ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent --ozone-platform=wayland
    ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --quick-access
  '';
  screenshotScript = pkgs.writeShellScriptBin "screenshot.sh" ''
    screenshot_path="${homeDir}/Downloads/screenshot.png"
    archive_dir="${homeDir}/Pictures/screenshots/$(${pkgs.hostname}/bin/hostname)"
    ${pkgs.coreutils}/bin/mkdir -p "$archive_dir"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - \
      | ${pkgs.coreutils}/bin/tee "$screenshot_path" "$archive_dir/$(${pkgs.coreutils}/bin/date +%Y-%m-%d-%H:%M:%S).png" \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  screenrecordScript = pkgs.writeShellScriptBin "screenrecord.sh" ''
    ${pkgs.coreutils}/bin/mkdir -p "${homeDir}/Videos"
    filename="${homeDir}/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    ${pkgs-stable.wf-recorder}/bin/wf-recorder -g "$(${pkgs-stable.slurp}/bin/slurp)" -t -f "$filename"
    ${pkgs.libnotify}/bin/notify-send "Screenrecord" "Saved to $filename"
  '';
  screenrecordKillScript = pkgs.writeShellScriptBin "screenrecord-kill.sh" ''
    ${pkgs.procps}/bin/killall -SIGINT wf-recorder
  '';
  battpopScript = pkgs.writeShellScriptBin "battpop.sh" ''
    ${pkgs.libnotify}/bin/notify-send "$(${pkgs.acpi}/bin/acpi -b | ${pkgs.gnugrep}/bin/grep -Eo '[0-9]+%' | ${pkgs.coreutils}/bin/head -1)"
  '';
  monitorsScript = pkgs.writeShellScriptBin "monitors.sh" ''
    monitor=$(${niri} msg -j outputs | ${pkgs.jq}/bin/jq -r 'keys[]' | ${dmenu} -p "Monitor")
    [ -n "$monitor" ] && ${niri} msg action focus-monitor "$monitor"
  '';
  ghosttyQuickTerminal = pkgs.writeShellScriptBin "ghostty-quick-terminal.sh" ''
    if ! ${pkgs.systemd}/bin/busctl --user status com.mitchellh.ghostty >/dev/null 2>&1; then
      ${pkgs.util-linux}/bin/setsid ${pkgs.ghostty}/bin/ghostty --gtk-single-instance=true --initial-window=false --quit-after-last-window-closed=false >/dev/null 2>&1 &
      for _ in $(${pkgs.coreutils}/bin/seq 1 50); do
        ${pkgs.systemd}/bin/busctl --user status com.mitchellh.ghostty >/dev/null 2>&1 && break
        ${pkgs.coreutils}/bin/sleep 0.1
      done
    fi
    exec ${pkgs.ghostty}/bin/ghostty +toggle-quick-terminal
  '';
  keybindHelper = pkgs.writeShellScriptBin "keybind-helper.sh" ''
    bind=$(${pkgs.gawk}/bin/awk '/^ *binds \{/,/^ *\}/' "$HOME/.config/niri/config.kdl" \
      | ${pkgs.gnugrep}/bin/grep -E '^ +[A-Za-z0-9+_.-]+ \{' \
      | ${dmenu} -p "Niri Keybinds")
    [ -z "$bind" ] && exit 0
    action=$(printf '%s' "$bind" | ${pkgs.gnused}/bin/sed -E 's/^ *[^ ]+ *\{ *//; s/ *\} *$//')
    ${niri} msg action $action
  '';
  lockAvatar = pkgs.runCommand "lock-avatar.png" {nativeBuildInputs = [pkgs.imagemagick];} ''
    magick ${config.home.file.".face".source} -resize 256x256^ -gravity center -extent 256x256 \
      \( +clone -fill black -colorize 100 -fill white -draw "circle 128,128 128,0" \) \
      -alpha off -compose CopyOpacity -composite $out
  '';
  noctaliaResetLockLayout = pkgs.writers.writePython3 "noctalia-reset-lock-layout" {libraries = [pkgs.python3Packages.tomlkit];} ''
    import sys

    import tomlkit

    path = sys.argv[1]
    with open(path) as f:
        doc = tomlkit.parse(f.read())

    changed = False
    if "lockscreen_widgets" in doc:
        del doc["lockscreen_widgets"]
        changed = True

    if len(sys.argv) > 2 and sys.argv[2] == "disable-lock":
        if "lockscreen" not in doc:
            doc["lockscreen"] = {}
        doc["lockscreen"]["enabled"] = False
        doc["lockscreen"]["lock_before_suspend"] = False
        behavior = doc.get("idle", {}).get("behavior", {})
        if "lock" in behavior:
            behavior["lock"]["enabled"] = False
        changed = True

    if len(sys.argv) > 3 and sys.argv[3] == "disable-screen-off":
        behavior = doc.get("idle", {}).get("behavior", {})
        if "screen-off" in behavior:
            behavior["screen-off"]["enabled"] = False
        changed = True

    if changed:
        with open(path, "w") as f:
            f.write(tomlkit.dumps(doc))
  '';
  lockWidget = type: cx: cy: boxWidth: boxHeight: settings: {
    inherit type cx cy settings;
    output = "";
    placement_width = 1920.0;
    placement_height = 1080.0;
    box_width = boxWidth;
    box_height = boxHeight;
  };
  lockText = {
    background = false;
    color = "#ffffff";
    font_family = "Noto Sans";
    shadow = false;
  };
  lockLoginBox = output: {
    name = "lockscreen-login-box@${output}";
    value = {
      type = "login_box";
      inherit output;
      cx = 960.0;
      cy = 967.0;
      placement_width = 1920.0;
      placement_height = 1080.0;
      box_width = 260.0;
      settings = {
        layout = "compact";
        show_login_button = false;
        show_password_reveal = false;
        show_keyboard_layout = false;
        center_password_text = true;
        background_opacity = 0.0;
        input_opacity = 0.35;
        input_radius = 10.0;
      };
    };
  };
in {
  options.heywoodlh.home.niri = {
    enable = mkEnableOption "the Niri desktop environment";
    lockScreen = mkOption {
      default = true;
      description = "Enable the Noctalia lock screen, idle auto-lock and lock keybind.";
      type = types.bool;
    };
    idleScreenOff = mkOption {
      default = true;
      description = "Blank the display after Noctalia's idle screen-off timeout.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    heywoodlh.home.onepassword.package = mkDefault pkgs._1password-gui;
    home.packages = with pkgs;
      [
        acpi
        adwaita-icon-theme
        bluez
        brillo
        grim
        jq
        libnotify
        pavucontrol
        playerctl
        procps
        pulseaudio
        slurp
        socat
        util-linux
        pkgs-stable.wf-recorder
        wireplumber
        wl-clipboard
        xdg-utils
        ydotool
        screenshotScript
        screenrecordScript
        screenrecordKillScript
        battpopScript
        monitorsScript
        ghosttyQuickTerminal
        keybindHelper
      ]
      ++ optionals onepasswordCfg.enable [onepasswordToggle];

    home.activation.noctaliaResetLockLayout = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -f "${config.xdg.stateHome}/noctalia/settings.toml" ]; then
        run ${noctaliaResetLockLayout} "${config.xdg.stateHome}/noctalia/settings.toml" ${if cfg.lockScreen then "keep-lock" else "disable-lock"} ${if cfg.idleScreenOff then "keep-screen-off" else "disable-screen-off"}
      fi
    '';

    programs.noctalia = {
      enable = true;
      settings = {
        shell = {
          polkit_agent = true;
          setup_wizard_enabled = false;
          telemetry_enabled = false;
          panel = {
            launcher_placement = "floating";
            launcher_position = "center";
            transparency_mode = "glass";
          };
          launcher = {
            layout = "simple";
            categories = false;
            show_app_origin_indicator = false;
          };
        };
        notification.enable_daemon = true;
        lockscreen = {
          enabled = cfg.lockScreen;
          lock_before_suspend = cfg.lockScreen;
          transition = [];
          blur_intensity = 0.5;
          tint_intensity = 0.1;
        };
        lockscreen_widgets = {
          enabled = true;
          widget =
            {
              date = lockWidget "clock" 960.0 97.0 300.0 32.0 (lockText
                // {
                  format = "{:%A %-d %B}";
                  center_text = true;
                });
              time = lockWidget "clock" 960.0 222.0 480.0 150.0 (lockText
                // {
                  format = "{:%-I:%M}";
                  center_text = true;
                });
            }
            // optionalAttrs (config.home.file ? ".face") {
              avatar = lockWidget "sticker" 960.0 713.0 72.0 72.0 {
                image_path = "${lockAvatar}";
                background = false;
              };
            }
            // listToAttrs (map lockLoginBox ["eDP-1" "eDP-2" "DP-1" "DP-2" "DP-3" "DP-4" "HDMI-A-1" "HDMI-A-2"]);
        };
        idle = {
          behavior_order = ["lock" "screen-off"];
          behavior = {
            lock = {
              enabled = cfg.lockScreen;
              timeout = 900;
              action = "lock";
            };
            screen-off = {
              enabled = cfg.idleScreenOff;
              timeout = 1200;
              action = "screen_off";
            };
          };
        };
        hooks.session_locked =
          [
            "${pkgs.playerctl}/bin/playerctl --all-players pause"
          ]
          ++ optionals onepasswordCfg.enable [
            "${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --lock"
          ];
        widget = {
          launcher = {
            custom_image = "${pkgs.nixos-icons}/share/icons/hicolor/256x256/apps/nix-snowflake-white.png";
            capsule = false;
            scale = 1.3;
          };
          workspaces = {
            capsule = false;
            focused_color = "#81a1c1";
            occupied_color = "#57627a";
            empty_color = "#57627a";
            active_pill_size = 1.6;
            inactive_pill_size = 1.6;
            pill_scale = 1.0;
          };
          clock = {
            format = "{:%a %d %b %H:%M}";
            custom_label = "󰥔";
            actions.left = "panel-toggle control-center notifications";
          };
          more = {
            type = "custom_button";
            glyph = "dots";
            tooltip = "Control Center";
            actions.left = "panel-toggle control-center";
          };
          notifications.hide_when_no_unread = true;
          volume.show_label = false;
          network.show_label = false;
          cpu = {
            type = "sysmon";
            stat = "cpu_usage";
            visualization = "none";
          };
          memory = {
            type = "sysmon";
            stat = "ram_used";
            visualization = "none";
          };
          battery.enabled = mkDefault false;
        };
        bar.main = {
          position = "top";
          thickness = 32;
          background_opacity = 0.0;
          margin_ends = 0;
          margin_edge = 0;
          radius = 0;
          concave_edge_corners = false;
          shadow = false;
          compositor_blur = false;
          padding = 8;
          widget_spacing = 7;
          font_family = "JetBrainsMono Nerd Font";
          font_weight = 700;
          color = "#eceff4";
          capsule = true;
          capsule_fill = "#57627a";
          capsule_radius = 4.0;
          capsule_thickness = 0.66;
          capsule_padding = 8;
          start = ["launcher" "workspaces"];
          center = [];
          end = ["group:more" "caffeine" "battery" "network" "clock"];
          capsule_group = [
            {
              id = "more";
              members = ["more" "tray" "notifications" "volume" "bluetooth" "cpu" "memory"];
              fill = "#57627a";
              radius = 4.0;
              padding = 8.0;
              accordion = true;
              accordion_direction = "start";
            }
          ];
        };
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
        categories = ["Utility"];
        icon = "media-record";
      };
      screenrecord-kill = {
        name = "Screenrecord (Kill)";
        genericName = "recorder-kill";
        comment = "Kill recording screen";
        exec = "${screenrecordKillScript}/bin/screenrecord-kill.sh";
        terminal = false;
        type = "Application";
        categories = ["Utility"];
        icon = "media-playback-stop";
      };
      monitor-switch = {
        name = "Monitor switch";
        genericName = "monitors";
        comment = "Focus another monitor";
        exec = "${monitorsScript}/bin/monitors.sh";
        terminal = false;
        type = "Application";
        categories = ["Utility"];
        icon = "video-display";
      };
      keybind-helper = {
        name = "keybind-helper";
        genericName = "keybinds";
        comment = "Show Niri keybinds";
        exec = "${keybindHelper}/bin/keybind-helper.sh";
        terminal = false;
        type = "Application";
        categories = ["Utility"];
        icon = "preferences-desktop-keyboard";
      };
    };

    wayland.windowManager.niri = {
      enable = true;
      settings = {
        _children =
          [
            {spawn-at-startup._args = ["${noctaliaBin}"];}
            {spawn-at-startup._args = ["${pkgs.gnome-keyring}/bin/gnome-keyring-daemon" "--start" "--components=secrets"];}
            {spawn-at-startup._args = ["${pkgs.ydotool}/bin/ydotoold"];}
            {spawn-at-startup._args = ["${pkgs.dbus}/bin/dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "DISPLAY" "XDG_CURRENT_DESKTOP"];}
            {spawn-at-startup._args = ["${pkgs.gsettings-desktop-schemas}/bin/gsettings" "set" "org.gnome.desktop.interface" "color-scheme" "prefer-dark"];}
            {
              window-rule = {
                match._props.title = "^(Authentication Required|Authenticate|Open File|Save File|File Upload|Save As|Open|Choose.*|Select.*)$";
                open-floating = true;
              };
            }
            {
              window-rule = {
                match._props.title = "^(Quick Access — 1Password)$";
                open-floating = true;
              };
            }
            {
              window-rule = {
                match._props.title = "^(Picture-in-Picture)$";
                open-floating = true;
              };
            }
            {
              window-rule = {
                match._props."app-id" = "dev.noctalia.Noctalia";
                open-floating = true;
                default-column-width.fixed = 1080;
                default-window-height.fixed = 920;
              };
            }
            {
              layer-rule = {
                match._props.namespace = "^(noctalia|noctalia-.*)$";
                background-effect.blur = true;
              };
            }
            {
              layer-rule = {
                match._props.namespace = "^noctalia-bar-.*$";
                background-effect.blur = false;
              };
            }
          ]
          ++ optionals onepasswordCfg.enable [
            {spawn-at-startup._args = ["${onepasswordCfg.wrapper}/bin/1password-gui-wrapper" "--silent"];}
          ]
          ++ optionals config.heywoodlh.home.librewolf.enable [
            {spawn-at-startup._args = ["${pkgs.xdg-utils}/bin/xdg-settings" "set" "default-web-browser" "librewolf.desktop"];}
          ];
        input = {
          keyboard.xkb.options = "caps:super";
          touchpad = {
            tap = {};
            natural-scroll = {};
            dwt = {};
          };
        };
        layout = {
          gaps = 8;
          center-focused-column = "never";
          preset-column-widths._children = [
            {proportion = 0.33333;}
            {proportion = 0.5;}
            {proportion = 0.66667;}
          ];
          default-column-width.proportion = 0.5;
          focus-ring = {
            width = 2;
            active-color = "#88c0d0";
            inactive-color = "#4c566a";
          };
        };
        prefer-no-csd = {};
        screenshot-path = "~/Pictures/screenshots/%Y-%m-%d-%H%M%S.png";
        binds =
          {
            "Super+Return" = {spawn = ["${pkgs.foot}/bin/foot"];};
            "Super+O" = {toggle-overview = {};};
            "Super+Q" = {close-window = {};};
            "Ctrl+Alt+T" = {spawn = ["${pkgs.foot}/bin/foot"];};
            "Ctrl+grave" = {spawn = ["${ghosttyQuickTerminal}/bin/ghostty-quick-terminal.sh"];};
            "Ctrl+Super+Space" = {spawn = ["${pkgs.emote}/bin/emote"];};
            "Super+Space" = {spawn-sh = "${noctaliaMsg} panel-toggle launcher";};
            "Super+S" = {spawn-sh = "${noctaliaMsg} panel-toggle control-center";};
            "Super+K" = {spawn-sh = "${noctaliaMsg} panel-toggle control-center";};
            "Super+comma" = {spawn-sh = "${noctaliaMsg} settings-toggle";};
            "XF86AudioLowerVolume" = {
              _props.allow-when-locked = true;
              spawn-sh = "${noctaliaMsg} volume-down";
            };
            "XF86AudioRaiseVolume" = {
              _props.allow-when-locked = true;
              spawn-sh = "${noctaliaMsg} volume-up";
            };
            "XF86AudioMute" = {
              _props.allow-when-locked = true;
              spawn-sh = "${noctaliaMsg} volume-mute";
            };
            "Ctrl+Shift+Space" = {spawn-sh = "${noctaliaMsg} media toggle";};
            "Ctrl+Shift+N" = {spawn-sh = "${noctaliaMsg} media next";};
            "Ctrl+Shift+P" = {spawn-sh = "${noctaliaMsg} media previous";};
            "XF86MonBrightnessUp" = {
              _props.allow-when-locked = true;
              spawn-sh = "${noctaliaMsg} brightness-up";
            };
            "XF86MonBrightnessDown" = {
              _props.allow-when-locked = true;
              spawn-sh = "${noctaliaMsg} brightness-down";
            };
            "Super+Shift+S" = {spawn = ["${screenshotScript}/bin/screenshot.sh"];};
            "Ctrl+Shift+B" = {spawn = ["${battpopScript}/bin/battpop.sh"];};
            "Super+Tab" = {spawn-sh = "${noctaliaMsg} window-switcher hold";};
            "Super+Shift+Tab" = {spawn-sh = "${noctaliaMsg} window-switcher hold reverse";};
            "Ctrl+Shift+E" = {quit = {};};
            "Ctrl+Shift+D" = {spawn-sh = "${pkgs.libnotify}/bin/notify-send \"$(date +%T)\"";};
            "Ctrl+Super+H" = {spawn = ["${keybindHelper}/bin/keybind-helper.sh"];};
            "Super+V" = {toggle-window-floating = {};};
            "Super+F" = {fullscreen-window = {};};
            "Super+backslash" = {switch-preset-column-width = {};};
            "Super+Left" = {focus-column-left = {};};
            "Super+Right" = {focus-column-right = {};};
            "Super+Up" = {focus-window-up = {};};
            "Super+Down" = {focus-window-down = {};};
            "Super+1" = {focus-workspace = 1;};
            "Super+2" = {focus-workspace = 2;};
            "Super+3" = {focus-workspace = 3;};
            "Super+4" = {focus-workspace = 4;};
            "Ctrl+Shift+1" = {move-column-to-workspace = 1;};
            "Ctrl+Shift+2" = {move-column-to-workspace = 2;};
            "Ctrl+Shift+3" = {move-column-to-workspace = 3;};
            "Ctrl+Shift+4" = {move-column-to-workspace = 4;};
            "Super+bracketleft" = {focus-column-left-or-last = {};};
            "Super+bracketright" = {focus-column-right-or-first = {};};
            "Super+Page_Up" = {focus-workspace-up = {};};
            "Super+Page_Down" = {focus-workspace-down = {};};
            "Ctrl+Shift+bracketleft" = {focus-monitor-left = {};};
            "Ctrl+Shift+bracketright" = {focus-monitor-right = {};};
            "Ctrl+Alt+Left" = {move-column-left = {};};
            "Ctrl+Alt+Right" = {move-column-right = {};};
            "Ctrl+Alt+Up" = {move-window-up = {};};
            "Ctrl+Alt+Down" = {move-window-down = {};};
          }
          // optionalAttrs cfg.lockScreen {
            "Super+L" = {spawn-sh = "${lockCmd}";};
          }
          // optionalAttrs onepasswordCfg.enable {
            "Ctrl+Super+S" = {spawn = ["${onepasswordToggle}/bin/1password-toggle.sh"];};
          };
      };
    };

    programs.foot.enable = true;
  };
}
