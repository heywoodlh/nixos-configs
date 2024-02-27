{ config, pkgs, ... }:

{
  home.file.".config/fish/config.fish".text = ''
    set -g PATH "${pkgs.atuin}/bin" $PATH
    ${pkgs.atuin}/bin/atuin init fish | source
  '';
}
