{ config, pkgs, home-manager, ... }:

{
  home.stateVersion = "23.05";
  programs.password-store = import ../../../home/pass.nix { inherit config; inherit pkgs; };
  programs.tmux = import ../../../home/tmux.nix { inherit config; inherit pkgs; };
  programs.vim = import ../../../home/vim.nix { inherit config; inherit pkgs; };
  programs.zsh = import ../../../home/zsh.nix { inherit config; inherit pkgs; };
}
