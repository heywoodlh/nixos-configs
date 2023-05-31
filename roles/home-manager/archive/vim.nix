{ config, pkgs, ... }:

{
  enable = true;
  extraConfig = ''
    if winheight(0) >= 35
    	set termwinsize=10x0
    	set confirm
    	set splitbelow
    end
    let g:airline_statusline_ontop=1
    let g:airline#extensions#tabline#enabled = 1
    " Nerdfonts
    let g:airline_powerline_fonts = 1
    " Clear terminal buffer on exit (without it, Airline messes up shell)
    set t_ti= t_te=
    " Set Nord Airline Theme
    let g:airline_theme='nord'
    " Enable ale with airline
    let g:airline#extensions#ale#enabled = 1

    syntax on

    colorscheme nord

    filetype plugin indent on
    let g:mapleader = "\<Space>"
    let g:maplocalleader = ','
    nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
    nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
    map <C-n> :NERDTreeToggle<CR>

    set number

    " Start Nerdtree only if width is greater than or equal to 80 columns
    "if winwidth(0) >= 100
    "	let g:NERDTreeWinSize=winwidth(0)/6
    "	autocmd VimEnter * NERDTree | wincmd p
    "endif
    " Start NERDTree when Vim starts with a directory argument.
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
        \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif

    " Vim-indentline config
    let g:indentLine_char = '⦙'
    set shiftwidth=4
    let g:vim_json_conceal=0
    let g:vim_json_syntax_conceal = 0
    let g:markdown_syntax_conceal=0
    augroup filetype_indent
      autocmd!
      autocmd FileType dockerfile let g:indentLine_enabled = 0
    augroup END

    " Custom keybinds
    nnoremap zz :wa <bar> :qa!<CR>
    nnoremap zq <bar> :qa!<CR>
    map <silent> <C-y> :w! ~/tmp/vimbuf <CR>:silent !cat ~/tmp/vimbuf <Bar> pbcopy<CR>:redraw!<CR>
    map <silent> <C-t> :term ++kill=term<CR>
    map <silent> <C-o> :FZF $HOME<CR>
    map <silent> <C-l> :set invnumber<CR>

    "" Vim-markdown-preview toggle
    nnoremap mdp :Glow<CR>

    command NoComments %s/#.*\n//g
    command GitAdd :w! <bar> !git add -v %
    command GitCommit !$gitmessage = ($gitmessage = read-host -prompt "commit message") && git commit -s -m ''${gitmessage}
    command GitPush !gpsup

    nnoremap ga :GitAdd<CR>
    nnoremap gc :GitCommit<CR>
    nnoremap gp :GitPush<CR>
    nnoremap nc :NoComments<CR>

    " Folding
    set foldmethod=syntax
    set foldlevel=99

    " Show matching characters like paranthesis, brackets, etc.
    set showmatch

    " tell vim to keep a backup file
    set backup
    " tell vim where to put its backup files
    set backupdir=~/tmp
    " tell vim where to put swap files
    set dir=~/tmp

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

    " Ignore case
    set ignorecase smartcase
  '';

  plugins = with pkgs.vimPlugins; [
    ale
    base16-vim
    colorizer
    copilot-vim
    fugitive
    glow-nvim
    indentLine
    nerdtree
    nord-vim
    SudoEdit-vim
    vim-airline
    vim-airline-themes
    vim-gitgutter
    vim-json
    vim-lastplace
    vim-sensible
    vim-sneak
    vim-terraform
  ];
}
