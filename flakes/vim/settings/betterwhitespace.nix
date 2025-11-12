{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ vim-better-whitespace ];
  rc = ''
    let g:better_whitespace_enabled=1
    augroup vimrc
        autocmd TermOpen * :DisableWhitespace
    augroup END
  '';
}
