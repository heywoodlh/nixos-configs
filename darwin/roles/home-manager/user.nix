{ config, pkgs, ... }:

{
  home.stateVersion = "23.05";
  # Zsh stuff
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    profileExtra = ''
      [[ -e ~/.bash_profile ]] && source ~/.bash_profile
    '';

    # Enable oh-my-zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aliases"
        "aws"
        "battery"
        "brew"
        "docker"
        "git"
        "helm"
        "kubectl"
        "macos"
        "nmap"
        "sudo"
      ];
      theme = "apple";
    };
  }; 

  programs.firefox = import ../../../roles/firefox/darwin.nix { inherit config; inherit pkgs; };
}
