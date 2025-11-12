{
  description = "heywoodlh wezterm flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.fish-flake.url = ../fish;
  inputs.nixgl.url = "github:nix-community/nixGL";

  outputs = { self, nixpkgs, fish-flake, flake-utils, nixgl, }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nixgl.overlay ];
      };
      myZellij = fish-flake.packages.${system}.zellij;
      jetbrains_nerdfont = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });
      settings = ''
        -- Add config folder to watchlist for config reloads.
        local wezterm = require 'wezterm';
        wezterm.add_to_config_reload_watch_list(wezterm.config_dir)

        -- Pull in the wezterm API
        local wezterm = require 'wezterm'

        -- This table will hold the configuration.
        local config = {}

        -- In newer versions of wezterm, use the config_builder which will
        -- help provide clearer error messages
        if wezterm.config_builder then
          config = wezterm.config_builder()
        end

        -- Nord color scheme:
        config.color_scheme = 'nord'
        config.font_size = 14.0

        -- Appearance tweaks
        config.window_decorations = "RESIZE"
        config.hide_tab_bar_if_only_one_tab = true
        config.audible_bell = "Disabled"
        config.window_background_opacity = 0.9

        -- Set Zellij to default shell
        config.default_prog = { "${myZellij}/bin/zellij" }

        -- Use Jetbrains font directory
        config.font_dirs = { "${jetbrains_nerdfont}/share/fonts" }
      '';
      berkeleymono-settings = pkgs.writeText "wezterm.lua" ''
        ${settings}

        config.font = wezterm.font_with_fallback {
          'Berkeley Mono',
          'JetBrainsMono Nerd Font Mono',
          'Iosevka Nerd Font Mono',
          'SF Mono Regular',
          'DejaVu Sans Mono',
        }
        return config
      '';
      non-berkeleymono-settings = pkgs.writeText "wezterm.lua" ''
        ${settings}

        config.font = wezterm.font_with_fallback {
          'JetBrainsMono Nerd Font Mono',
          'Iosevka Nerd Font Mono',
          'SF Mono Regular',
          'DejaVu Sans Mono',
        }
        return config
      '';
    in {
      packages = rec {
        wezterm = pkgs.writeShellScriptBin "wezterm" ''
            if ${pkgs.wezterm}/bin/wezterm ls-fonts --list-system | grep -iq 'Berkeley Mono'
            then
                ${pkgs.wezterm}/bin/wezterm --config-file ${berkeleymono-settings} $@
            else
                ${pkgs.wezterm}/bin/wezterm --config-file ${non-berkeleymono-settings} $@
            fi
          '';
        wezterm-gl = pkgs.writeShellScriptBin "wezterm" ''
            if ${pkgs.wezterm}/bin/wezterm ls-fonts --list-system | grep -iq 'Berkeley Mono'
            then
              ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.wezterm}/bin/wezterm --config-file ${berkeleymono-settings} $@
            else
              ${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL ${pkgs.wezterm}/bin/wezterm --config-file ${non-berkeleymono-settings} $@
            fi
          '';
          default = wezterm;
        };
      }
    );
}
