{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ vim-json ];
  rc = ''
    let g:vim_json_conceal=0
    let g:vim_json_syntax_conceal = 0
  '';
}
