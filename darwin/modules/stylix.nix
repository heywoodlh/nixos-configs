{ config, lib, ... }:

let
  cfg = config.heywoodlh.stylix;
in {
  config = lib.mkIf cfg.enable {
    homebrew.casks = [
      "font-jetbrains-mono"
      "font-noto-color-emoji"
    ];
  };
}
