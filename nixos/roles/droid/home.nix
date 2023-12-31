{ config, lib, pkgs, ... }:
{
  home.stateVersion = "23.05";
  home.file.".config/fish/config.fish" = {
    text = ''
      if status is-interactive
        set -gx PATH "$HOME/.nix-profile/bin:$PATH"
      end
    '';
  };
}
