{ stdenv, xclip, wl-clipboard, ... }:

{
  rc = if stdenv.isDarwin then ''
    " MacOS specific config
    " Yank to system clipboard with Ctrl + y
    noremap <silent> <C-y> "*y
  '' else ''
    let g:clipboard = {
      \   'name': 'wayland-clip',
      \   'copy': {
      \      '+': '${xclip}/bin/xclip -sel clipboard',
      \      '*': '${xclip}/bin/xclip -sel clipboard',
      \    },
      \   'paste': {
      \      '+': {-> systemlist('${xclip}/bin/xclip -sel clipboard -o')},
      \      '*': {-> systemlist('${xclip}/bin/xclip -sel clipboard -o')},
      \   },
      \   'cache_enabled': 1,
      \ }
    " Yank to system clipboard with Ctrl + y
    noremap <silent> <C-y> "+y
  '';
}
