{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [ indentLine ];
  rc = ''
    " Vim-indentline config
    let g:markdown_syntax_conceal=0
    augroup filetype_indent
      autocmd!
      autocmd FileType dockerfile let g:indentLine_enabled = 0
    augroup END
  '';
}
