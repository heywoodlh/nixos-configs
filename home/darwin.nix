{ config, pkgs, home-manager, nur, lib, myFlakes, determinate-nix, ... }:

let
  system = pkgs.system;
  nixPkg = determinate-nix.packages.${system}.default;
  homeDir = config.home.homeDirectory;
  myTmux = myFlakes.packages.${system}.tmux;
in {
  imports = [
    ./base.nix
    ./desktop.nix
  ];

  home.file."bin/battpop.sh" = {
    enable = true;
    executable = true;
    text = ''
    '';
  };

  home.packages = [
    pkgs.fleetctl
    pkgs.m-cli
    pkgs.mas
    pkgs.pinentry_mac
    nixPkg # $HOME/.nix-profile/bin/nix will be prioritized over /var/nix/profiles/default/bin/nix
  ];

  home.shellAliases = {
    ls = "ls --color";
  };

  home.file."Pictures/wallpaper.png" = {
    enable = true;
    source = ../assets/nord-apple.png;
  };

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

  home.file.".zshenv" = {
    text = ''
      # Managed with home-manager, check `~/opt/nixos-configs/home/darwin.nix`
      # Start Tmux on ssh (i.e. ensure Terminal.app does not use tmux for testing tmux-less environment)
      if [[ ''${SSH_TTY} ]]
      then
          [ -z $TMUX ] && { ${myTmux}/bin/tmux new-session && exit;}
      fi
    '';
  };

  home.file.".config/iterm2/iterm2-profiles.json" = {
    text = import ./iterm/iterm2-profiles.nix { inherit myTmux; };
  };
  home.file.".config/iterm2/com.googlecode.iterm2.plist" = {
    text = import ./iterm/com.googlecode.iterm2.plist.nix { inherit myTmux; };
  };
  home.file.".config/iterm2/README.md" = {
    source = ./iterm/README.md;
  };

  #1Password config
  home.file.".config/git/config" = {
    text = ''
[user]
  signingkey = ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ==

[gpg]
  format = ssh

[gpg "ssh"]
  program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"

[commit]
  gpgsign = true
    '';
  };

  home.activation = {
    aerc-link = ''
      ln -s ${homeDir}/.config/aerc ${homeDir}/Library/Preferences/aerc &>/dev/null || true
    '';
  };

  # Run Lima VM always in background
  heywoodlh.home.lima = {
    enable = true;
    enableDocker = true;
  };

  heywoodlh.home.applications = [
    {
      name = "virt-manager";
      command = "${pkgs.virt-manager}/bin/virt-manager";
    }
  ];
  heywoodlh.home.darwin.defaults.enable = true;
}
