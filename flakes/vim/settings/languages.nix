{ pkgs, vimPlugins, ... }:

{
  plugins = with vimPlugins; [
    vim-go
    jedi-vim
  ];
  rc = ''
    " add jedi python module for jedi-vim
    python3 sys.path.append('${pkgs.python312Packages.jedi}/lib/python3.12/site-packages')
    python3 sys.path.append('${pkgs.python312Packages.parso}/lib/python3.12/site-packages')

    " remap omnifunc for go files to Ctrl+Space
    autocmd FileType go inoremap <C-Space> <C-X><C-O>
  '';
}
