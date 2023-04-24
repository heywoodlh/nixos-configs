{ config, pkgs, home-manager, ... }:

{
  dconf.settings = import ../../../roles/home-manager/gnome/dconf.nix { inherit config; inherit pkgs; };
  home.packages = import ../../../roles/home-manager/packages.nix { inherit config; inherit pkgs; }; 
  programs.alacritty = import ../../../roles/home-manager/alacritty.nix { inherit config; inherit pkgs; };
  programs.firefox = import ../../../roles/home-manager/firefox/linux.nix { inherit config; inherit pkgs; };
  programs.password-store = import ../../../roles/home-manager/pass.nix { inherit config; inherit pkgs; }; 
  programs.tmux = import ../../../roles/home-manager/tmux.nix { inherit config; inherit pkgs; };
  programs.vim = import ../../../roles/home-manager/vim.nix { inherit config; inherit pkgs; };
  programs.zsh = import ../../../roles/home-manager/zsh.nix { inherit config; inherit pkgs; };
}
