{ config, lib, pkgs, myFlakes, search-tui, ... }:

with lib;

let
  cfg = config.heywoodlh.home.search-tui;
  system = pkgs.stdenv.hostPlatform.system;
  op-wrapper = "${myFlakes.packages.${system}.op-wrapper}/bin/op-wrapper";
  tokenFile = "~/.config/kagi/session-token";
  tomlFormat = pkgs.formats.toml { };
  defaultSettings = {
    default_engine = "kagi";
    engines.kagi.token_file = tokenFile;
  };
  unwrapped = search-tui.packages.${system}.default;
  wrapped = pkgs.writeShellScriptBin "search" ''
    if [[ ! -s "$HOME/.config/kagi/session-token" ]]; then
      ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/kagi"
      tmp="$(${pkgs.coreutils}/bin/mktemp)"
      if ${op-wrapper} item get m7jgf2i7odnem6kafb6bslyck4 --fields api-key --reveal > "$tmp"; then
        ${pkgs.coreutils}/bin/mv "$tmp" "$HOME/.config/kagi/session-token"
      else
        ${pkgs.coreutils}/bin/rm -f "$tmp"
        echo "Unable to populate Kagi session token. Exiting." >&2
        exit 1
      fi
    fi
    exec ${unwrapped}/bin/search "$@"
  '';
in
{
  options.heywoodlh.home.search-tui = {
    enable = mkEnableOption "heywoodlh search-tui configuration";

    package = mkOption {
      type = types.package;
      default = wrapped;
      description = ''
        The search-tui package installed as `search`. The default wrapper
        populates the Kagi session token from 1Password before running it.
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = ''
        Extra settings merged into `search-tui/config.toml`.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."search-tui/config.toml".source = tomlFormat.generate "search-tui-config.toml" (
      recursiveUpdate defaultSettings cfg.settings
    );
  };
}
