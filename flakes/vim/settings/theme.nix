{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ nordic-nvim transparent-nvim ];
  rc = ''
    " set comments to light blue
    hi Comment ctermfg=LightBlue
    colorscheme nordic
    let g:transparent_enabled = v:true
  '';
}
