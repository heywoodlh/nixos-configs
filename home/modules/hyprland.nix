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
  onepasswordToggle = pkgs.writeShellScriptBin "1password-toggle.sh" ''
    # Check if 1password is running
    ps aux | grep -i 1password | grep -iq silent || ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --silent --ozone-platform-hint=wayland

    # Open 1password quick access
    ${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --quick-access
  '';
  lockCmdPfx = "" + optionalString (onepasswordCfg.enable) "${onepasswordCfg.wrapper}/bin/1password-gui-wrapper --lock;";
  lockCmd = "${lockCmdPfx} ${pkgs.playerctl}/bin/playerctl --all-players pause; ${pkgs.hyprlock}/bin/hyprlock";
  screenshotScript = pkgs.writeShellScriptBin "screenshot.sh" ''
    screenshot_path="${homeDir}/Downloads/screenshot.png"
    ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - \
      | ${pkgs.coreutils}/bin/tee "$screenshot_path" \
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
    heywoodlh.home.onepassword.package = mkForce pkgs._1password-gui;
    home.packages = with pkgs; [
      acpi
      adwaita-icon-theme
      bluez
      brillo
      dunst
      grim
      hyprmon
      libnotify
      pavucontrol
      playerctl
      procps
      pulseaudio
      slurp
      swaybg
      util-linux
      pkgs-stable.wf-recorder
      wireplumber
      wl-clipboard
      xdg-desktop-portal-hyprland
      ydotool
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
          bluetooth_more_cmd = "${pkgs.blueman}/bin/blueman-manager";
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

    programs.hyprlock.enable = true;

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
          },
        })

        -- Apps to start on login
        hl.on("hyprland.start", function()
          hl.exec_cmd("${pkgs.hyprland}/bin/hyprctl setcursor Adwaita 24")
          hl.exec_cmd("${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland")
          hl.exec_cmd("${pkgs.dunst}/bin/dunst")
          hl.exec_cmd("${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=secrets")
          hl.exec_cmd("${pkgs.ydotool}/bin/ydotoold")

          -- DBUS
          hl.exec_cmd("${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all")

          -- Workarounds
          hl.exec_cmd("/run/current-system/sw/bin/systemctl restart --user hypridle.service")
          hl.exec_cmd("/run/current-system/sw/bin/systemctl restart --user ashell.service")
          hl.exec_cmd("/run/current-system/sw/bin/systemctl restart --user hyprpaper.service")
          hl.exec_cmd("/run/current-system/sw/bin/systemctl restart --user kdeconnect.service")
          hl.exec_cmd("/run/current-system/sw/bin/systemctl restart --user hyprpolkitagent.service")
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
        hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("${pkgs.fuzzel}/bin/fuzzel -I"))
        -- Lock screen
        hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("${lockCmd}"))
        -- Remap caps lock to super
        hl.config({ input = { kb_options = "caps:super" } })
        -- Audio
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -t \"1000\" -e \"Volume: $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)\""), { repeating = true })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -t \"1000\" -e \"Volume: $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)\""), { repeating = true })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -t \"1000\" -e \"Volume: $(${pkgs.wireplumber}/bin/wpctl get-volume @DEFAULT_AUDIO_SINK@)\""), { repeating = true })
        hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause"))
        hl.bind("CTRL + SHIFT + Space", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -e \"Media: $(playerctl status)\""))
        hl.bind("CTRL + SHIFT + N", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl next"))
        hl.bind("CTRL + SHIFT + N", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -e \"Media: next track\""))
        hl.bind("CTRL + SHIFT + P", hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl previous"))
        hl.bind("CTRL + SHIFT + P", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -e \"Media: previous track\""))

        -- Backlight
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${pkgs.brillo}/bin/brillo -A 5"), { repeating = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -e \"Brightness: $(${pkgs.brillo}/bin/brillo)\""), { repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${pkgs.brillo}/bin/brillo -U 5"), { repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${pkgs.libnotify}/bin/notify-send -e \"Brightness: $(${pkgs.brillo}/bin/brillo)\""), { repeating = true })

        -- Productivity
        hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("${screenshotScript}/bin/screenshot.sh"))
        hl.bind("CTRL + SHIFT + B", hl.dsp.exec_cmd("${battpopScript}/bin/battpop.sh"))
        hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("${applicationsScript}/bin/applications.sh"))
        hl.bind("CTRL + SHIFT + E", hl.dsp.exit())
        hl.bind("CTRL + SHIFT + D", hl.dsp.exec_cmd("${pkgs.bash}/bin/bash -c '${pkgs.libnotify}/bin/notify-send $(date \"+%T\")'"))
        hl.bind("CTRL + SUPER + H", hl.dsp.exec_cmd("${keybindHelper}/bin/keybind-helper.sh"))

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
      '' + optionalString (config.heywoodlh.home.hypr-rdp.enable) ''
        hl.on("hyprland.start", function()
          hl.exec_cmd("${config.heywoodlh.home.hypr-rdp.package}/bin/hypr-rdp")
        end)
      '';
      xwayland = {
        enable = true;
      };
    };

    # Foot terminal for non-special workspaces
    programs.foot.enable = true;

    # Wallpaper daemon
    services.hyprpaper.enable = true;

    # KDE Connect
    services.kdeconnect.enable = true;

    # Polkit authentication agent
    services.hyprpolkitagent.enable = true;

    # Idle/suspend daemon
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "${pkgs.hyprland}/bin/hyprctl eval \"hl.dispatch(hl.dsp.dpms('on'))\"";
          ignore_dbus_inhibit = false;
          lock_cmd = "${lockCmd}";
          unlock_cmd = "/run/current-system/sw/bin/systemctl --user restart ashell.service";
          before_sleep_cmd = "${lockCmd}";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "${lockCmd}";
          }
          {
            timeout = 1200;
            on-timeout = "${pkgs.hyprland}/bin/hyprctl eval \"hl.dispatch(hl.dsp.dpms('off'))\"";
            on-resume = "${pkgs.hyprland}/bin/hyprctl eval \"hl.dispatch(hl.dsp.dpms('on'))\"";
          }
        ];
      };
    };
  };
}
