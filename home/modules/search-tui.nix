{ config, lib, pkgs, myFlakes, search-tui, ... }:

with lib;

let
  cfg = config.heywoodlh.home.search-tui;
  system = pkgs.stdenv.hostPlatform.system;
  op-wrapper = "${myFlakes.packages.${system}.op-wrapper}/bin/op-wrapper";
  tomlFormat = pkgs.formats.toml { };
  defaultSettings = {
    default_engine = "kagi";
    ui.theme = "catppuccin-macchiato";
    engines.kagi.token_command = "${op-wrapper} item get m7jgf2i7odnem6kafb6bslyck4 --fields api-key --reveal";
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
