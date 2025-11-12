{ pkgs, vimPlugins, ... }:

{
  plugins = with vimPlugins; [ glow-nvim ];
  rc = ''
    nnoremap mdp :Glow %<CR>
    lua << EOF
      require('glow').setup({
        glow_path = "${pkgs.glow}/bin/glow",
      })
    EOF
  '';
}
