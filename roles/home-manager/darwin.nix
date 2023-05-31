{ config, pkgs, home-manager, nur, lib, ... }:

{
  imports = [
    ./base.nix
    ./firefox/darwin.nix
  ];

  nix = {
    package = lib.mkForce pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  home.packages = with pkgs; [
    colima
    m-cli
    mas
    pinentry_mac
  ];

  programs.zsh = {
    initExtra = ''
      # MacOS specific ZSH config
      # Architecture specific differences
      if [[ $(arch) == 'arm64' ]]
      then
        export PATH="/opt/homebrew/bin:$PATH"
      else
        export PATH="/usr/local/bin:$PATH"
      fi

      function toon {
        echo -n ""
      }

      if [[ -e $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/ ]]
      then
        export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
      fi

      function darwin-switch {
        git -C ~/opt/nixos-configs pull origin master
        darwin-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure $@
      }
      function docker {
        docker_bin="$(command which docker)"
        colima list | grep default | grep -q Running || colima start default # Start/create default colima instance if not running/created
        $docker_bin $@
      }
    '';
    oh-my-zsh.plugins = [
      "macos"
    ];
  };

  home.file.".zshenv".text = lib.mkForce ''
    [[ -e $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]] && . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

    # Only source this once
    if [[ -z "$__HM_ZSH_SESS_VARS_SOURCED" ]]
    then
      export __HM_ZSH_SESS_VARS_SOURCED=1
    fi

    ZSH="${pkgs.oh-my-zsh}/share/oh-my-zsh";
    ZSH_CACHE_DIR="/var/empty/.cache/oh-my-zsh";
  '';

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
    text = import ./darwin/iterm/iterm2-profiles.nix;
  };
  home.file.".config/iterm2/com.googlecode.iterm2.plist" = {
    text = import ./darwin/iterm/com.googlecode.iterm2.plist.nix;
  };
  home.file."bin/bwmenu" = {
    text = import ./darwin/bwmenu.nix;
    executable = true;
  };

  programs.rbw.settings = {
    pinentry = "pinentry-mac";
  };
}
