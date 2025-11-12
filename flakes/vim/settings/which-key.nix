{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ which-key-nvim ];
  rc = ''
    nnoremap ? :WhichKey<CR>
    lua << EOF
      require('which-key').setup{
        preset = "helix"
      }
    EOF
  '';
}
