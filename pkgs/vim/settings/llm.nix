{
  vimPlugins,
  ...
}: {
  plugins = with vimPlugins; [
    copilot-vim
    codecompanion-nvim
    codecompanion-history-nvim
    llm-nvim
  ];
}
