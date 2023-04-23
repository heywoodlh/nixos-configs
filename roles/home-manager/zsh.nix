{ config, pkgs, ... }:

{
  enable = true;
  enableCompletion = true;
  enableAutosuggestions = true;
  enableSyntaxHighlighting = true;

  # Set variables here because Darwin has a bug with zshenv https://github.com/nix-community/home-manager/issues/1782#issuecomment-777500002
  initExtra = ''
    export EDITOR="vim"
    export PAGER="less"
    export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/heywoodlh/bin:/run/current-system/sw/bin:$PATH"
  
    # MacOS specific config
    if [[ $(uname) == 'Darwin' ]]
    then
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
        darwin-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure
      }
    fi

    # Linux specific config 
    if [[ $(uname) == 'Linux' ]]
    then
      alias pbcopy='xclip -selection clipboard'

      function toon {
        echo -n ""
      }

      #NixOS specific config
      if grep -q 'ID=nixos' /etc/os-release
      then
        is_nixos = "true"
      fi
      if [[ $is_nixos == "true" ]]
      then
        function nixos-switch {
          git -C ~/opt/nixos-configs pull origin master
          sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure
        }
      else
        function home-switch {
          git -C ~/opt/nixos-configs pull origin master
          nix --extra-experimental-features "nix-command flakes" run github:heywoodlh/nixos-configs#homeConfigurations.$(whoami).activationPackage --impure
        } 
      fi
    fi
  '';

  # Enable oh-my-zsh
  oh-my-zsh = {
    enable = true;
    plugins = [
      "aliases"
      "ansible"
      "aws"
      "battery"
      "brew"
      "docker"
      "git"
      "helm"
      "kubectl"
      "nmap"
      "pass"
      "python"
      "rbw"
      "ssh-agent"
      "sudo"
      "tmux"
    ];
    theme = "apple";
  };
}
