{ vimPlugins, ... }:

{
  plugins = with vimPlugins; [vim-airline vim-airline-themes];
  rc = ''
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
  '';
}
