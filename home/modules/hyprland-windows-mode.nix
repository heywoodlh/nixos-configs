{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.hyprland-windows-mode;
  noctaliaCfg = config.programs.noctalia;
  noctaliaBin = "${noctaliaCfg.package}/bin/noctalia";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprbars = "${pkgs.hyprlandPlugins.hyprbars}/lib/libhyprbars.so";
  tomlFormat = pkgs.formats.toml { };
  jsonFormat = pkgs.formats.json { };

  win11Kde = pkgs.fetchFromGitHub {
    owner = "yeyushengfan258";
    repo = "Win11OS-kde";
    rev = "9f021c3e71da7baf59a0614ab858d53b1e455fd5";
    hash = "sha256-R1l0YG+UEfFKPJd/pQJ3aJzWKg1ru0gWasW7zStK1Ig=";
  };
  wallpaper = "${win11Kde}/wallpaper/Win11OS-dark/contents/images/3840x2400.jpg";

  selawik = pkgs.stdenvNoCC.mkDerivation {
    pname = "selawik";
    version = "1.01";
    src = pkgs.fetchzip {
      url = "https://github.com/microsoft/Selawik/releases/download/1.01/Selawik_Release.zip";
      hash = "sha256-BbjXJ8HFXrRklMOnGXyZIZeQ5Oksda4AqQXHmNqN6AQ=";
      stripRoot = false;
    };
    installPhase = ''
      install -Dm644 -t $out/share/fonts/truetype *.ttf
    '';
  };

  windowsLogo = pkgs.runCommand "windows-logo.png" { nativeBuildInputs = [ pkgs.librsvg ]; } ''
    rsvg-convert -w 256 -h 256 -o $out ${pkgs.writeText "windows-logo.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 88 88">
        <defs>
          <linearGradient id="g" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0" stop-color="#3ccbf4"/>
            <stop offset="1" stop-color="#0067c0"/>
          </linearGradient>
        </defs>
        <g fill="url(#g)">
          <rect width="42" height="42" rx="2"/>
          <rect x="46" width="42" height="42" rx="2"/>
          <rect y="46" width="42" height="42" rx="2"/>
          <rect x="46" y="46" width="42" height="42" rx="2"/>
        </g>
      </svg>
    ''}
  '';

  palette = jsonFormat.generate "Windows11.json" {
    version = 2;
    dark = {
      primary = "#4cc2ff";
      on_primary = "#000000";
      secondary = "#60cdff";
      on_secondary = "#000000";
      tertiary = "#0078d4";
      on_tertiary = "#ffffff";
      error = "#ff99a4";
      on_error = "#000000";
      surface = "#202020";
      on_surface = "#ffffff";
      surface_container = "#2d2d2d";
      on_surface_variant = "#c5c5c5";
      outline_variant = "#3d3d3d";
      shadow = "#000000";
      hover = "#383838";
      on_hover = "#ffffff";
      terminal = {
        background = "#0c0c0c";
        foreground = "#cccccc";
        cursor = "#ffffff";
        cursor_text = "#0c0c0c";
        selection_bg = "#ffffff";
        selection_fg = "#0c0c0c";
        normal = {
          black = "#0c0c0c";
          red = "#c50f1f";
          green = "#13a10e";
          yellow = "#c19c00";
          blue = "#0037da";
          magenta = "#881798";
          cyan = "#3a96dd";
          white = "#cccccc";
        };
        bright = {
          black = "#767676";
          red = "#e74856";
          green = "#16c60c";
          yellow = "#f9f1a5";
          blue = "#3b78ff";
          magenta = "#b4009e";
          cyan = "#61d6d6";
          white = "#f2f2f2";
        };
      };
    };
  };

  quickSettings = { actions.left = "panel-toggle control-center"; };
  noctaliaSettings = recursiveUpdate (removeAttrs noctaliaCfg.settings [ "bar" "widget" "plugins" "plugin_settings" "lockscreen_widgets" ]) {
    shell = {
      font_family = "Selawik";
      panel = {
        launcher_placement = "floating";
        launcher_position = "bottom_center";
        control_center_placement = "floating";
        control_center_position = "bottom_right";
      };
      launcher = {
        layout = "full";
        width = 640;
        search_position = "top";
        default_view = "all";
        app_grid = true;
        show_app_origin_indicator = false;
      };
    };
    theme = {
      mode = "dark";
      source = "custom";
      custom_palette = "Windows11";
    };
    wallpaper = {
      enabled = true;
      default.path = wallpaper;
    };
    notification.position = "bottom_right";
    osd.position = "bottom_center";
    plugins.enabled = [ ];
    widget = {
      start = {
        type = "launcher";
        custom_image = "${windowsLogo}";
        scale = 1.2;
      };
      search = {
        type = "launcher";
        glyph = "search";
      };
      taskbar = {
        item_spacing = 6;
        icon_scale = 1.3;
        active_indicator_color = "#4cc2ff";
      };
      tray.drawer = true;
      network = quickSettings // { show_label = false; };
      volume = quickSettings // { show_label = false; };
      battery = quickSettings // { enabled = noctaliaCfg.settings.widget.battery.enabled or false; };
      clock = {
        format = "{:%-I:%M %p}\n{:%-m/%-d/%Y}";
        actions.left = "panel-toggle control-center notifications";
      };
    };
    bar.taskbar = {
      position = "bottom";
      thickness = 48;
      background_opacity = 0.92;
      compositor_blur = true;
      border = "outline_variant";
      border_width = 1.0;
      radius = 0;
      margin_ends = 0;
      margin_edge = 0;
      concave_edge_corners = false;
      shadow = false;
      padding = 12;
      widget_spacing = 4;
      color = "#ffffff";
      font_family = "Selawik";
      font_weight = 400;
      capsule = false;
      start = [ ];
      center = [ "start" "search" "taskbar" ];
      end = [ "tray" "network" "volume" "battery" "clock" ];
    };
  };

  noctaliaConfig = pkgs.runCommand "windows-mode-noctalia.toml" { } ''
    ${noctaliaBin} config validate ${tomlFormat.generate "config.toml" noctaliaSettings}
    cp ${tomlFormat.generate "config.toml" noctaliaSettings} $out
  '';

  noctaliaHome = pkgs.linkFarm "windows-mode-noctalia" [
    { name = "noctalia/config.toml"; path = noctaliaConfig; }
    { name = "noctalia/palettes/Windows11.json"; path = palette; }
  ];

  dispatch = lua: "${hyprctl} dispatch ${escapeShellArg lua}";

  enableLua = pkgs.writeText "windows-mode-enable.lua" ''
    WindowsMode = { floating = {} }

    hl.config({
      general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 1,
        resize_on_border = true,
        col = {
          active_border = "rgba(ffffff26)",
          inactive_border = "rgba(ffffff14)",
        },
      },
      decoration = {
        rounding = 8,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
          enabled = true,
          range = 24,
          render_power = 3,
          color = "rgba(00000080)",
        },
      },
      plugin = {
        hyprbars = {
          bar_height = 32,
          bar_color = "rgb(202020)",
          col = { text = "rgb(ffffff)" },
          bar_text_font = "Selawik",
          bar_text_size = 10,
          bar_text_align = "left",
          bar_padding = 12,
          bar_button_padding = 20,
          bar_part_of_window = true,
          bar_precedence_over_border = true,
          on_double_click = ${builtins.toJSON (dispatch ''hl.dsp.window.fullscreen({ mode = "maximized" })'')},
        },
      },
    })

    hl.plugin.hyprbars.add_button({
      bg_color = "rgba(00000000)",
      fg_color = "rgb(ffffff)",
      size = 14,
      icon = "✕",
      action = ${builtins.toJSON (dispatch "hl.dsp.window.close()")},
    })
    hl.plugin.hyprbars.add_button({
      bg_color = "rgba(00000000)",
      fg_color = "rgb(ffffff)",
      size = 14,
      icon = "☐",
      action = ${builtins.toJSON (dispatch ''hl.dsp.window.fullscreen({ mode = "maximized" })'')},
    })
    hl.plugin.hyprbars.add_button({
      bg_color = "rgba(00000000)",
      fg_color = "rgb(ffffff)",
      size = 14,
      icon = "—",
      action = ${builtins.toJSON (dispatch ''hl.dsp.window.move({ workspace = "special:minimized", follow = false })'')},
    })

    hl.curve("windows-mode", { type = "bezier", points = { { 0.1, 0.9 }, { 0.2, 1.0 } } })
    hl.animation({ leaf = "windowsIn",  enabled = true, speed = 2.5, bezier = "windows-mode", style = "popin 90%" })
    hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,   bezier = "windows-mode", style = "popin 90%" })
    hl.animation({ leaf = "fade",       enabled = true, speed = 2,   bezier = "windows-mode" })

    hl.window_rule({
      name  = "windows-mode-float",
      match = { class = ".*" },
      float = true,
      center = true,
    })

    hl.on("window.active", function(w)
      if w and w.workspace and w.workspace.name == "special:minimized" then
        hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace().id, window = w }))
      end
    end)

    hl.bind("ALT + F4", hl.dsp.window.close())
    hl.bind("ALT + Tab", hl.dsp.exec_cmd("${noctaliaBin} msg window-switcher hold"))
    hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd("${noctaliaBin} msg window-switcher hold reverse"))
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

    for _, w in ipairs(hl.get_windows()) do
      if w.floating then
        WindowsMode.floating[w.address] = true
      else
        hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
      end
    end
  '';

  disableLua = pkgs.writeText "windows-mode-disable.lua" ''
    if WindowsMode then
      for _, w in ipairs(hl.get_windows()) do
        if w.workspace and w.workspace.name == "special:minimized" then
          hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace().id, window = w }))
        end
        if w.floating and not w.pinned and not WindowsMode.floating[w.address] then
          hl.dispatch(hl.dsp.window.float({ action = "unset", window = w }))
        end
      end
    end
  '';

  gtkSettings = {
    gtk-theme = "'Fluent-Dark'";
    icon-theme = "'Fluent-dark'";
    cursor-theme = "'Posy_Cursor'";
    font-name = "'Selawik 11'";
    document-font-name = "'Selawik 11'";
    color-scheme = "'prefer-dark'";
  };

  windowsMode = pkgs.writeShellApplication {
    name = "windows-mode";
    runtimeInputs = with pkgs; [ coreutils dconf psmisc ];
    text = ''
      interface=/org/gnome/desktop/interface/
      snapshot="''${XDG_STATE_HOME:-$HOME/.local/state}/windows-mode/interface.dconf"
      runtime="''${XDG_RUNTIME_DIR:?}/hypr/''${HYPRLAND_INSTANCE_SIGNATURE:-none}/windows-mode"
      lock="$XDG_RUNTIME_DIR/noctalia-''${WAYLAND_DISPLAY:-wayland-0}.lock"

      restore_gtk() {
        [ -f "$snapshot" ] || return 0
        dconf reset -f "$interface"
        dconf load "$interface" < "$snapshot"
        rm -f "$snapshot"
      }

      stop_noctalia() {
        fuser -s -k -TERM "$lock" || return 0
        for _ in $(seq 50); do
          fuser -s "$lock" || return 0
          sleep 0.1
        done
        fuser -s -k -KILL "$lock" || true
      }

      start_noctalia() {
        ${hyprctl} -q dispatch "hl.dsp.exec_cmd('$1${noctaliaBin}')"
      }

      enable() {
        mkdir -p "$runtime/state" "$(dirname "$snapshot")"
        [ -f "$snapshot" ] || dconf dump "$interface" > "$snapshot"
        ${concatStringsSep "\n  " (mapAttrsToList (k: v: ''dconf write "$interface"${k} "${v}"'') gtkSettings)}
        ${hyprctl} -q setcursor Posy_Cursor 24
        ${hyprctl} -q plugin load ${hyprbars}
        ${hyprctl} -q eval "dofile('${enableLua}')"
        stop_noctalia
        start_noctalia "NOCTALIA_CONFIG_HOME=${noctaliaHome} NOCTALIA_STATE_HOME=$runtime/state "
        touch "$runtime/active"
      }

      disable() {
        stop_noctalia
        ${hyprctl} -q eval "dofile('${disableLua}')" || true
        ${hyprctl} -q plugin unload ${hyprbars} || true
        ${hyprctl} -q reload
        ${hyprctl} -q setcursor Adwaita 24
        restore_gtk
        start_noctalia ""
        rm -rf "$runtime"
      }

      case "''${1:-toggle}" in
        toggle)
          if [ -f "$runtime/active" ]; then disable; else enable; fi
          ;;
        on) [ -f "$runtime/active" ] || enable ;;
        off) disable ;;
        restore) [ -f "$runtime/active" ] || restore_gtk ;;
        *)
          echo "usage: windows-mode [toggle|on|off|restore]" >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  options.heywoodlh.home.hyprland-windows-mode = {
    enable = mkOption {
      default = false;
      description = ''
        Add a "Windows Mode (Undercover)" app that temporarily makes Hyprland look like Windows 11.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      windowsMode
      selawik
      fluent-gtk-theme
      fluent-icon-theme
      posy-cursors
    ];

    xdg.desktopEntries.windows-mode = {
      name = "Windows Mode (Undercover)";
      genericName = "Undercover mode";
      comment = "Toggle a temporary Windows 11 look";
      exec = "${windowsMode}/bin/windows-mode";
      terminal = false;
      type = "Application";
      categories = [ "Utility" ];
      icon = "${windowsLogo}";
    };

    wayland.windowManager.hyprland.extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("${windowsMode}/bin/windows-mode restore")
      end)
    '';
  };
}
