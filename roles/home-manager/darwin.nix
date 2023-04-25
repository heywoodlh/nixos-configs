{ config, pkgs, home-manager, nur, ... }:

{
  imports = [
    ./desktop.nix
    ./firefox/darwin.nix
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
        darwin-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure
      }
    '';
    oh-my-zsh.plugins = [
      "macos"
    ];
  };
}
