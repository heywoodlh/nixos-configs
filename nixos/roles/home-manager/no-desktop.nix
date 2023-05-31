{ config, pkgs, home-manager, ... }:

{
  home.stateVersion = "23.05";
  programs.password-store = import ../../../roles/home-manager/pass.nix { inherit config; inherit pkgs; };
  programs.tmux = import ../../../roles/home-manager/tmux.nix { inherit config; inherit pkgs; };
  programs.vim = import ../../../roles/home-manager/vim.nix { inherit config; inherit pkgs; };
  programs.zsh = import ../../../roles/home-manager/zsh.nix { inherit config; inherit pkgs; };
}
