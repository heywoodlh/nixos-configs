{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ oil-nvim ];
  rc = ''
    lua << EOF
      require("oil").setup()
    EOF
  '';
}
