{ pkgs, ... }:

{
  rc = ''
    syntax on

    filetype plugin indent on
    let g:mapleader = "\<Space>"
    let g:maplocalleader = ','

    " Turn on line numbers
    set number

    set shiftwidth=4

    " Custom keybinds
    nnoremap zq <bar> :qa!<CR>
    map <silent> <C-l> :set invnumber<CR>

    command NoComments %s/#.*\n//g
    nnoremap nc :NoComments<CR>

    " Folding
    set foldmethod=syntax
    set foldlevel=99

    " Show matching characters like paranthesis, brackets, etc.
    set showmatch

    " Cursor settings:

    "  1 -> blinking block
    "  2 -> solid block
    "  3 -> blinking underscore
    "  4 -> solid underscore
    "  5 -> blinking vertical bar
    "  6 -> solid vertical bar

    " back to line cursor when in normal mode
    let &t_SI.="\e[5 q" "SI = INSERT mode
    let &t_SR.="\e[5 q" "SR = REPLACE mode
    let &t_EI.="\e[5 q" "EI = NORMAL mode (ELSE)

    " Convert tabs to spaces
    set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

    " Ignore case with search
    set ignorecase smartcase

    "This unsets the "last search pattern" register by hitting return
    nnoremap <CR> :noh<CR><CR>

    " Text wrapping commands
    command WrapLines setlocal textwidth=80 wrapmargin=2
    command NoWrapLines setlocal textwidth& wrapmargin&

    " Markdown configuration
    " Auto wrap
    autocmd FileType markdown setlocal textwidth=80 wrapmargin=2
    " Spell check
    autocmd FileType markdown setlocal spell spelllang=en_us
    " Disable copilot
    autocmd FileType markdown Copilot disable

    if filereadable(expand("~/.config/vim/vimrc"))
      source ~/.config/vim/vimrc
    endif
  '';
}
