{ config, pkgs, lib, ... }:

{
  home.stateVersion = "23.05";
  # Zsh stuff
  home.file.".zshenv".text = lib.mkForce ''
    . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" 

    # Only source this once
    if [[ -z "$__HM_ZSH_SESS_VARS_SOURCED" ]]
    then
      export __HM_ZSH_SESS_VARS_SOURCED=1
    fi
    
    ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ZSH_CACHE_DIR="/var/empty/.cache/oh-my-zsh";
  '';

  programs.alacritty = import ../../../roles/home-manager/alacritty.nix { inherit config; inherit pkgs; };

  programs.firefox = import ../../../roles/home-manager/firefox/darwin.nix { inherit config; inherit pkgs; };

  programs.tmux = import ../../../roles/home-manager/tmux.nix { inherit config; inherit pkgs; };
  
  programs.vim = import ../../../roles/home-manager/vim.nix { inherit config; inherit pkgs; };

  programs.zsh = import ../../../roles/home-manager/zsh.nix { inherit config; inherit pkgs; };

  home.file."bin/choose-launcher.zsh" = {
    text = ''
      #!/run/current-system/sw/bin/zsh
      source ~/.zshrc
      application_dirs=( /Applications /System/Applications /System/Library/CoreServices /System/Applications/Utilities $HOME/Applications )
      
      ### Simple MacOS application launcher that relies on choose: https://github.com/chipsenkbeil/choose
      ### brew install choose-gui
      
      if ! command -v choose > /dev/null
      then
      	echo 'Please install choose. Exiting.'
      fi
      
      selection=$(for dir in ''${application_dirs[@]}; do ls ''${dir};done | grep ".app" | rev | cut -d/ -f1 | rev | /usr/bin/sort -u | choose)
      
      open -a "''${selection}"
    '';
    executable = true;
  };
  home.file.".config/iterm2/iterm2-profiles.json" = {
    text = import ./iterm2-profiles.nix;
  };

}
