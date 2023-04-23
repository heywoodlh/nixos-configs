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

    # MacOS specific actions
    if [[ $(uname) == 'Darwin' ]]
    then
      if [[ $(arch) == 'arm64' ]]
      then
        export PATH="/opt/homebrew/bin:$PATH"
      else
        export PATH="/usr/local/bin:$PATH"
      fi

      if [[ -e $HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/ ]]
      then
        export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
      fi
    fi

    # Linux specific actions
    if [[ $(uname) == 'Linux' ]]
    then
      alias pbcopy='xclip -selection clipboard'
    fi
  '';

  # Enable oh-my-zsh
  oh-my-zsh = {
    enable = true;
    plugins = [
      "aliases"
      "aws"
      "battery"
      "git"
      "helm"
      "kubectl"
      "nmap"
      "sudo"
    ];
    theme = "af-magic";
  };
}
