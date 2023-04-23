{ config, pkgs, ... }:

{
  home.stateVersion = "23.05";

  programs.alacritty = import ../../roles/home-manager/alacritty.nix { inherit config; inherit pkgs; };

  programs.firefox = import ../../roles/home-manager/firefox/linux.nix { inherit config; inherit pkgs; };

  programs.tmux = import ../../roles/home-manager/tmux.nix { inherit config; inherit pkgs; };
  
  programs.vim = import ../../roles/home-manager/vim.nix { inherit config; inherit pkgs; };

  programs.zsh = import ../../roles/home-manager/zsh.nix { inherit config; inherit pkgs; };
}
