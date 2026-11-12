{
  config,
  pkgs,
  nixpkgs-stable,
  lib,
  ...
}:

with lib;

let
  cfg = config.heywoodlh.home.hyprland;
  pkgs-stable = import nixpkgs-stable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
    };
  };
  onepasswordCfg = config.heywoodlh.home.onepassword;
  homeDir = config.home.homeDirectory;
  noctaliaBin = "${config.programs.noctalia.package}/bin/noctalia";
  noctaliaMsg = "${noctaliaBin} msg";
  dmenu = "${noctaliaBin} dmenu";
  onepasswordToggle = pkgs.writeShellScriptBin "1password-toggle.sh" ''
    # Check if 1password is running
    ps aux | grep -i 1password | grep -iq silent || ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent --ozone-platform-hint=wayland

    # Open 1password quick access
    ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --quick-access
  '';
  lockCmd = "${noctaliaMsg} session lock";
  screenshotScript = pkgs.writeShellScriptBin "screenshot.sh" ''
    screenshot_path="${homeDir}/Downloads/screenshot.png"
    archive_dir="${homeDir}/Pictures/screenshots/$(${pkgs.hostname}/bin/hostname)"
    ${pkgs.coreutils}/bin/mkdir -p "$archive_dir"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - \
      | ${pkgs.coreutils}/bin/tee "$screenshot_path" "$archive_dir/$(${pkgs.coreutils}/bin/date +%Y-%m-%d-%H:%M:%S).png" \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
  screenrecordScript = pkgs.writeShellScriptBin "screenrecord.sh" ''
    mkdir -p "${homeDir}/Videos"
    filename="${homeDir}/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
    ${pkgs-stable.wf-recorder}/bin/wf-recorder -g "$(${pkgs-stable.slurp}/bin/slurp)" -t -f $filename
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
    selection=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq -r '.[] | select(.focused == false) | (.name + ": " + .description)' | ${dmenu} -p "Monitor" | ${pkgs.coreutils}/bin/cut -d':' -f1)
    hyprctl dispatch focusmonitor $selection
    ${pkgs.libnotify}/bin/notify-send "Monitor switched to $selection"
  '';
  keybindHelper = pkgs.writeShellScriptBin "keybind-helper.sh" ''
    HYPR_CONF="$HOME/.config/hypr/hyprland.conf"
    # extract the keybindings from hyprland.conf
    # format: "MOD + KEY<TAB>description<TAB>command"
    mapfile -t BINDINGS < <(grep '^bind=' "$HYPR_CONF" | \
        sed -e 's/  */ /g' -e 's/bind=//g' -e 's/, /,/g' -e 's/ # /,/' | \
        awk -F, '{cmd=""; for(i=3;i<NF;i++) cmd=cmd $(i) " "; printf "%s + %s\t%s\t%s\n", $1, $2, $NF, cmd}')
    CHOICE=$(printf '%s\n' "''${BINDINGS[@]}" | ${dmenu} -p "Hyprland Keybinds")
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
    heywoodlh.home.onepassword.package = mkForce pkgs._1password-gui;
    home.packages = with pkgs; [
      acpi
      adwaita-icon-theme
      bluez
      brillo
      grim
      hyprmon
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
      xdg-desktop-portal-hyprland
      xdg-utils
      ydotool
    ] ++ [
      screenshotScript
      screenrecordScript
      screenrecordKillScript
      battpopScript
      monitorsScript
      keybindHelper
    ] ++ optionals (config.heywoodlh.home.onepassword.enable) [
      onepasswordToggle
    ];

    programs.noctalia = {
      enable = true;
      settings = {
        shell = {
          polkit_agent = true;
          telemetry_enabled = false;
        };
        notification.enable_daemon = true;
        lockscreen = {
          enabled = true;
          lock_before_suspend = true;
        };
        idle = {
          behavior_order = [ "lock" "screen-off" ];
          behavior = {
            lock = {
              enabled = true;
              timeout = 900;
              action = "lock";
            };
            screen-off = {
              enabled = true;
              timeout = 1200;
              action = "screen_off";
            };
          };
        };
        hooks.session_locked = [
          "${pkgs.playerctl}/bin/playerctl --all-players pause"
        ] ++ optionals onepasswordCfg.enable [
          "${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --lock"
        ];
        plugins = {
          enabled = [
            "davemhammer/tailscale"
            "profidev/hypr-screen-mirror"
            "maddingo/hypr-layout-switcher"
          ];
          auto_update = "all";
        };
        widget = {
          tailscale.type = "davemhammer/tailscale:status";
          screen-mirror.type = "profidev/hypr-screen-mirror:widget";
          tiling-layout.type = "maddingo/hypr-layout-switcher:toggle";
        };
        bar.main = {
          position = "top";
          start = [ "launcher" "workspaces" "tiling-layout" ];
          center = [ "clock" ];
          end = [
            "media"
            "tray"
            "privacy"
            "notifications"
            "tailscale"
            "screen-mirror"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "control-center"
            "session"
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

    # Hyprland
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland; # use nixpkgs-provided hyprland
      configType = "lua";
      extraConfig = ''
        -- Fix blurry X11 apps, hidpi
        hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
        hl.env("XCURSOR_SIZE", "24")

        hl.config({
          general = {
            no_focus_fallback = true,
            layout = "dwindle",
            gaps_in = 5,
            gaps_out = 10,
          },
          dwindle = {
            preserve_split = true,
          },
          master = {
            new_status = "master",
          },
        })

        for ws = 1, 4 do
          hl.workspace_rule({ workspace = tostring(ws), persistent = true })
        end

        -- Apps to start on login
        hl.on("hyprland.start", function()
          hl.exec_cmd("${pkgs.hyprland}/bin/hyprctl setcursor Adwaita 24")
          hl.exec_cmd("${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland")
          hl.exec_cmd("${noctaliaBin}")
          hl.exec_cmd("${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets")
          hl.exec_cmd("${pkgs.ydotool}/bin/ydotoold")

          -- DBUS
          hl.exec_cmd("${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all")
        end)

        -- Dark mode for apps
        hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")

        -- Start terminal in special workspace so I can toggle it
        hl.workspace_rule({
          workspace = "special:terminal",
          on_created_empty = "${pkgs.ghostty}/bin/ghostty --font-size=12",
        })

        hl.window_rule({
          name  = "special-terminal-whitelist",
          match = {
            workspace = "s[true]n[e:terminal]",
            class     = "negative:^(com.mitchellh.ghostty|1password|emote)$",
          },
          workspace = "previous silent",
        })

        hl.window_rule({
          name  = "ghostty",
          match = { class = "^(com.mitchellh.ghostty)$" },
        })

        -- Keep floating windows and dialogs on screen
        hl.window_rule({
          name  = "float-clamp",
          match = { float = true },
          max_size = "((monitor_w*0.9)) ((monitor_h*0.9))",
        })

        hl.window_rule({
          name  = "dialogs",
          match = { title = "^(Authentication Required|Authenticate|Open File|Save File|File Upload|Save As|Open|Choose.*|Select.*)$" },
          float = true,
          size = "((monitor_w*0.6)) ((monitor_h*0.7))",
          center = true,
        })

        -- Noctalia
        hl.window_rule({
          name  = "noctalia-settings",
          match = { class = "^(dev.noctalia.Noctalia)$" },
          float = true,
          size = { 1080, 920 },
        })

        hl.layer_rule({
          name = "noctalia-no-anim",
          match = {
            namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
          },
          no_anim = true,
        })

        hl.layer_rule({
          name = "noctalia-blur",
          match = {
            namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
          },
          ignore_alpha = 0.5,
          blur = true,
          blur_popups = true,
        })

        -- Animations
        hl.config({
          animations = {
            enabled = true,
          },
        })
        hl.curve("md3_standard",  { type = "bezier", points = { { 0.2,  0.0  }, { 0,    1.0  } } })
        hl.curve("md3_decel",     { type = "bezier", points = { { 0.05, 0.7  }, { 0.1,  1    } } })
        hl.curve("md3_accel",     { type = "bezier", points = { { 0.3,  0    }, { 0.8,  0.15 } } })
        hl.curve("overshot",      { type = "bezier", points = { { 0.05, 0.9  }, { 0.1,  1.05 } } })
        hl.curve("hyprnostretch", { type = "bezier", points = { { 0.05, 0.9  }, { 0.1,  1.0  } } })
        hl.curve("win10",         { type = "bezier", points = { { 0,    0    }, { 0,    1    } } })
        hl.curve("gnome",         { type = "bezier", points = { { 0,    0.85 }, { 0.3,  1    } } })
        hl.curve("funky",         { type = "bezier", points = { { 0.46, 0.35 }, { -0.2, 1.2  } } })
        hl.animation({ leaf = "windows",    enabled = true, speed = 2,         bezier = "overshot",  style = "slide" })
        hl.animation({ leaf = "border",     enabled = true, speed = 10,        bezier = "default" })
        hl.animation({ leaf = "fade",       enabled = true, speed = 0.0000001, bezier = "default" })
        hl.animation({ leaf = "workspaces", enabled = true, speed = 4,         bezier = "md3_decel", style = "slide" })

        hl.config({
          misc = {
            disable_hyprland_logo = true,
            disable_splash_rendering = true,
            -- suppress_portal_warnings = true,
          },
          ecosystem = {
            no_update_news = true,
            no_donation_nag = true,
          },
        })

        -- 1Password Quick Access
        hl.window_rule({
          name  = "1password-quick-access",
          match = { title = "^(Quick Access — 1Password)$" },
          float = true,
          stay_focused = true,
        })

        -- Firefox PiP
        hl.window_rule({
          name  = "firefox-pip",
          match = { title = "^(Picture-in-Picture)$" },
          move = "((monitor_w*0.68)) ((monitor_h*0.02))",
          float = true,
          opacity = "0.95 0.75",
          pin = true,
          keep_aspect_ratio = true,
        })

        -- Gestures
        hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

        hl.config({
          input = {
            touchpad = {
              natural_scroll = true,
              disable_while_typing = true,
            },
          },
        })

        -- Hide hardware cursor (0 = Disabled)
        hl.config({ cursor = { no_hardware_cursors = 0 } })

        -- General Keybindings
        local mainMod = "SUPER"
        -- Terminal
        hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("${pkgs.foot}/bin/foot"))
        hl.bind("CTRL + ALT + T", hl.dsp.exec_cmd("${pkgs.foot}/bin/foot"))
        hl.bind("CTRL + grave", hl.dsp.workspace.toggle_special("terminal"))
        -- Emote picker
        hl.bind("CTRL + SUPER + Space", hl.dsp.exec_cmd("${pkgs.emote}/bin/emote"))
        -- Launcher
        hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("${noctaliaMsg} panel-toggle launcher"))
        hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("${noctaliaMsg} panel-toggle control-center"))
        hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("${noctaliaMsg} settings-toggle"))
        -- Lock screen
        hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("${lockCmd}"))
        -- Remap caps lock to super
        hl.config({ input = { kb_options = "caps:super" } })
        -- Audio
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${noctaliaMsg} volume-down"), { locked = true, repeating = true })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${noctaliaMsg} volume-up"), { locked = true, repeating = true })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${noctaliaMsg} volume-mute"), { locked = true })
        hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("${noctaliaMsg} media toggle"))
        hl.bind("CTRL + SHIFT + N", hl.dsp.exec_cmd("${noctaliaMsg} media next"))
        hl.bind("CTRL + SHIFT + P", hl.dsp.exec_cmd("${noctaliaMsg} media previous"))

        -- Backlight
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${noctaliaMsg} brightness-up"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${noctaliaMsg} brightness-down"), { locked = true, repeating = true })

        -- Productivity
        hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("${screenshotScript}/bin/screenshot.sh"))
        hl.bind("CTRL + SHIFT + B", hl.dsp.exec_cmd("${battpopScript}/bin/battpop.sh"))
        hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("${noctaliaMsg} window-switcher hold"))
        hl.bind(mainMod .. " + SHIFT + Tab", hl.dsp.exec_cmd("${noctaliaMsg} window-switcher hold reverse"))
        hl.bind("CTRL + SHIFT + E", hl.dsp.exit())
        hl.bind("CTRL + SHIFT + D", hl.dsp.exec_cmd("${pkgs.bash}/bin/bash -c '${pkgs.libnotify}/bin/notify-send $(date \"+%T\")'"))
        hl.bind("CTRL + SUPER + H", hl.dsp.exec_cmd("${keybindHelper}/bin/keybind-helper.sh"))

        -- Tiling
        hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))
        hl.bind(mainMod .. " + backslash", hl.dsp.exec_cmd("${noctaliaMsg} plugin maddingo/hypr-layout-switcher:poller all cycle"))
        hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
        hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
        hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
        hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

        -- Navigation
        hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
        hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
        hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
        hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
        hl.bind("CTRL + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
        hl.bind("CTRL + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
        hl.bind("CTRL + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
        hl.bind("CTRL + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
        hl.bind(mainMod .. " + bracketleft", hl.dsp.focus({ workspace = "r-1" }))
        hl.bind(mainMod .. " + bracketright", hl.dsp.focus({ workspace = "r+1" }))
        hl.bind("CTRL + SHIFT + bracketleft", hl.dsp.focus({ monitor = "left" }))
        hl.bind("CTRL + SHIFT + bracketright", hl.dsp.focus({ monitor = "right" }))
        hl.bind("CTRL + ALT + left", hl.dsp.window.move({ direction = "left" }))
        hl.bind("CTRL + ALT + right", hl.dsp.window.move({ direction = "right" }))
        hl.bind("CTRL + ALT + up", hl.dsp.window.move({ direction = "up" }))
        hl.bind("CTRL + ALT + down", hl.dsp.window.move({ direction = "down" }))

        -- Keyboard-driven mouse
        hl.define_submap("cursor", function()
          -- Jump cursor to a position
          hl.bind("a", hl.dsp.exec_cmd("${pkgs.hyprland}/bin/hyprctl dispatch submap reset && ${pkgs.wl-kbptr}/bin/wl-kbptr && ${pkgs.hyprland}/bin/hyprctl dispatch submap cursor"))
          -- Cursor movement
          hl.bind("j", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer move 0 10"), { repeating = true })
          hl.bind("k", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer move 0 -10"), { repeating = true })
          hl.bind("l", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer move 10 0"), { repeating = true })
          hl.bind("h", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer move -10 0"), { repeating = true })
          -- Left button
          hl.bind("s", hl.dsp.exec_cmd("${pkgs.ydotool}/bin/ydotool click 0xC0"), { repeating = true })
          hl.bind("y", hl.dsp.exec_cmd("${pkgs.ydotool}/bin/ydotool click 0xC0"), { repeating = true })
          -- Middle button
          hl.bind("d", hl.dsp.exec_cmd("${pkgs.ydotool}/bin/ydotool click 0xC2"), { repeating = true })
          -- Right button
          hl.bind("f", hl.dsp.exec_cmd("${pkgs.ydotool}/bin/ydotool click 0xC1"), { repeating = true })
          hl.bind("u", hl.dsp.exec_cmd("${pkgs.ydotool}/bin/ydotool click 0xC1"), { repeating = true })
          -- Scroll up and down
          hl.bind("e", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer scroll 10 0"), { repeating = true })
          hl.bind("r", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer scroll -10 0"), { repeating = true })
          -- Scroll left and right
          hl.bind("t", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer scroll 0 -10"), { repeating = true })
          hl.bind("g", hl.dsp.exec_cmd("${pkgs.wlrctl}/bin/wlrctl pointer scroll 0 10"), { repeating = true })
          -- Exit cursor submap
          -- If you do not use cursor timeout or cursor:hide_on_key_press, you can delete its respective calls.
          hl.bind("escape", hl.dsp.exec_cmd("${pkgs.hyprland}/bin/hyprctl keyword cursor:inactive_timeout 3; ${pkgs.hyprland}/bin/hyprctl keyword cursor:hide_on_key_press true; ${pkgs.hyprland}/bin/hyprctl dispatch submap reset"))
        end)
        -- Entrypoint
        -- If you do not use cursor timeout or cursor:hide_on_key_press, you can delete its respective calls.
        hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("${pkgs.hyprland}/bin/hyprctl keyword cursor:inactive_timeout 0; ${pkgs.hyprland}/bin/hyprctl keyword cursor:hide_on_key_press false; ${pkgs.hyprland}/bin/hyprctl dispatch submap cursor"))

        -- Cursor
        hl.config({ cursor = { inactive_timeout = 3 } })
      '' + optionalString (config.heywoodlh.home.onepassword.enable) ''
        hl.on("hyprland.start", function()
          hl.exec_cmd("${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent")
        end)
        hl.bind("CTRL + SUPER + S", hl.dsp.exec_cmd("${onepasswordToggle}/bin/1password-toggle.sh"))
      '' + optionalString (config.heywoodlh.home.librewolf.enable) ''
        hl.on("hyprland.start", function()
          hl.exec_cmd("${pkgs.xdg-utils}/bin/xdg-settings set default-web-browser librewolf.desktop")
        end)
      '';
      xwayland = {
        enable = true;
      };
    };

    # Foot terminal for non-special workspaces
    programs.foot.enable = true;
  };
}
