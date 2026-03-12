{ config, lib, pkgs, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.home.ghostty;
  stdenv = pkgs.stdenv;
  system = stdenv.hostPlatform.system;
  myTmux = myFlakes.packages.${system}.tmux;
in {
  options = {
    heywoodlh.home.ghostty = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh vicinae configuration.
        '';
        type = types.bool;
      };
      command = mkOption {
        default = "${myTmux}/bin/tmux";
        description = ''
          Ghostty default command.
        '';
        type = types.str;
      };
      fontSize = mkOption {
        default = if stdenv.isDarwin then 16 else 14;
        description = ''
          Ghostty font size.
        '';
        type = types.int;
      };
      quickTerminalKeybind = mkOption {
        default = "global:ctrl+grave_accent=toggle_quick_terminal";
        description = ''
          Keybinding for Quick Terminal.
        '';
        type = types.str;
      };
      extraSettings = mkOption {
        default = {};
        description = ''
          Extra settings to append to ghostty home-manager configuration.
        '';
        type = types.attrs;
      };
    };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = if stdenv.isDarwin then null else pkgs.ghostty;
      settings = {
        command = cfg.command;
        auto-update = "off";
        font-size = cfg.fontSize;
        bell-features = "no-system,no-audio,attention,title,border";
        background-opacity = 0.95;
      } // optionalAttrs (stdenv.isDarwin) {
        macos-window-shadow = false;
        initial-window = false;
        window-decoration = "auto";
        quick-terminal-space-behavior = "remain";
        quick-terminal-animation-duration = 0.1;
        quick-terminal-autohide = false;
        quick-terminal-position = "center";
        quick-terminal-size = "99%,97%";
        keybind = [
          cfg.quickTerminalKeybind
        ];
      } // optionalAttrs (stdenv.isLinux) {
      } // cfg.extraSettings;
    };
  };
}
