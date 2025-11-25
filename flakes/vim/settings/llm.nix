{ pkgs, vimPlugins, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in {
  plugins = with vimPlugins; [
    copilot-vim
    codecompanion-nvim
    codecompanion-history-nvim
    llm-nvim
  ];
}
