{ config, lib, pkgs, search-tui, ... }:

with lib;

let
  cfg = config.heywoodlh.home.search-tui;
  tomlFormat = pkgs.formats.toml { };
  defaultSettings = {
    default_engine = "kagi";
    ui.theme = "catppuccin-macchiato";
  };
in
{
  imports = [ search-tui.homeManagerModules.default ];

  options.heywoodlh.home.search-tui = {
    enable = mkEnableOption "heywoodlh search-tui configuration";

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Extra settings merged into `search-tui/config.toml`.

        Credentials are not configured here; use search-tui's `:login`
        command, which stores them outside the Nix store.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.search-tui = {
      enable = true;
      settings = recursiveUpdate defaultSettings cfg.settings;
    };
  };
}
