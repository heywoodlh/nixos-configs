{ vimPlugins, git, ... }:

{
  plugins = with vimPlugins; [ nerdtree nerdtree-git-plugin vim-nerdtree-syntax-highlight vim-devicons ];
  rc = ''
    if executable("git")
      " Placeholder because I don't know how to do 'if not'
    else
      let g:NERDTreeGitStatusGitBinPath = '${git}/bin/git'
    endif

    map <C-n> :NERDTreeToggle<CR>
    " Exit Vim if NERDTree is the only window remaining in the only tab.
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | call feedkeys(":quit\<CR>:\<BS>") | endif
  '';
}
