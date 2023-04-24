{ config, pkgs, home-manager, ... }:

{
  # Import nur
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  home.username = "heywoodlh";
  home.homeDirectory = "/home/heywoodlh";

  # home-manager shared configs
  dconf.settings =  import ../roles/home-manager/gnome/dconf.nix { inherit config; inherit pkgs; };
  home.packages =  import ../roles/home-manager/packages.nix { inherit config; inherit pkgs; }; 
  programs.alacritty =  import ../roles/home-manager/alacritty.nix { inherit config; inherit pkgs; };
  programs.firefox =  import ../roles/home-manager/firefox/linux.nix { inherit config; inherit pkgs; };
  programs.password-store =  import ../roles/home-manager/pass.nix { inherit config; inherit pkgs; }; 
  programs.tmux =  import ../roles/home-manager/tmux.nix { inherit config; inherit pkgs; };
  programs.vim =  import ../roles/home-manager/vim.nix { inherit config; inherit pkgs; };
  programs.zsh =  import ../roles/home-manager/zsh.nix { inherit config; inherit pkgs; };

  home.file.".config/rbw/config.json" = {
    text = ''
      {
        "email": "l.spencer.heywood@protonmail.com",
        "base_url": null,
        "identity_url": null,
        "lock_timeout": 3600,
        "pinentry": "pinentry-gnome3",
        "client_cert_path": null
      }
    '';
  };


  home.stateVersion = "23.05";
}
