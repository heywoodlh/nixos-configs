{ vimPlugins, git, ... }:

{
  plugins = with vimPlugins; [ vim-gitgutter ];

  rc = ''
    let g:gitgutter_git_executable = "${git}/bin/git"
  '';

}
