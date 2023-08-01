{ config, pkgs, home-manager, nur, lib, fish-configs, ... }:

let
  system = pkgs.system;
in {
  imports = [
    ./base.nix
    ./desktop.nix
    ./firefox/darwin.nix
  ];

  nix = {
    package = lib.mkForce pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  home.packages = [
    fish-configs.packages.${system}.fish
    pkgs.colima
    pkgs.m-cli
    pkgs.mas
    pkgs.pinentry_mac
    pkgs.tiny
  ];

  home.shellAliases = {
    ls = "ls --color";
  };

  programs.git = {
    extraConfig = {
      user = {
        signingkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ==";
      };
      gpg = {
        format = "ssh";
      };
      "gpg \"ssh\"" = {
        program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
      commit = {
        gpgsign = "true";
      };
    };
  };

  programs.zsh = {
    initExtra = ''
      # MacOS specific ZSH config
      # Architecture specific differences
      if [[ $(arch) == 'arm64' ]]
      then
        export PATH="$PATH:/opt/homebrew/bin"
      else
        export PATH="$PATH:/usr/local/bin"
      fi

      function toon {
        echo -n ""
      }

      if [[ -e ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock ]]
      then
        export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
      fi
    '';
    oh-my-zsh.plugins = [
      "macos"
    ];
  };

  home.file."bin/darwin-switch" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      [[ -d ~/opt/nixos-configs ]] || git clone https://github.com/heywoodlh/nixos-configs
      git -C ~/opt/nixos-configs pull origin master
      darwin-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure $@
    '';
  };

  home.file."bin/docker" = {
    enable = true;
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pkgs.colima}/bin/colima list | grep default | grep -q Running || ${pkgs.colima}/bin/colima start default # Start/create default colima instance if not running/created
      ${pkgs.docker-client}/bin/docker ''$@
    '';
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

      selection=$(for dir in ''${application_dirs[@]}; do /bin/ls ''${dir};done | grep ".app" | rev | cut -d/ -f1 | rev | /usr/bin/sort -u | choose)

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
