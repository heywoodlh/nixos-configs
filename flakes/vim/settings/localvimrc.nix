{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ vim-localvimrc ];
  rc = ''
    let g:localvimrc_persistent=2
  '';
}
