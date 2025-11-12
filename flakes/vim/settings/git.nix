{ pkgs, ... }:

{
  rc = ''
    command GitAdd :w! <bar> :Git add -v %

    nnoremap ga :GitAdd<CR>
  '';
}
