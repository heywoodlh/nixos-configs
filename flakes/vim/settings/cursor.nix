{ vimPlugins, pkgs, ... }:

{
  plugins = with vimPlugins; [ vim-visual-multi ];
  rc = ''
    " emulate helix keybinds for multi-cursor
    let g:VM_maps = {}
    let g:VM_maps["Add Cursor Down"] = '<S-C>'
    let g:VM_maps["Add Cursor Up"] = '<,>'

    let g:VM_silent_exit = 1

    " disable conflicting keybind
    let g:VM_maps["Goto Next"] = ""
    let g:VM_maps["Goto Prev"] = ""
  '';
}
