{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ./base.nix
  ];
  # So that `nix search` works
  nix = lib.mkForce {
    package = pkgs.nix;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
  };

  programs.zsh = {
    initExtra = ''
      # Linux specific config
      if [[ $(uname) == 'Linux' ]]
      then
        PINENTRY_PROGRAM="${pkgs.pinentry-rofi}/bin/pinentry-rofi"
        alias pbcopy='xclip -selection clipboard'

        if [[ -e ~/.1password/agent.sock ]]
        then
          export SSH_AUTH_SOCK=~/.1password/agent.sock
        fi

        # Ansible fix for https://github.com/NixOS/nixpkgs/issues/223151
        alias ansible='LC_ALL=C.UTF-8 ansible'
        alias ansible-pull='LC_ALL=C.UTF-8 ansible-pull'
        alias ansible-playbook='LC_ALL=C.UTF-8 ansible-playbook'
        alias ansible-operator='LC_ALL=C.UTF-8 ansible-operator'
        alias ansible-galaxy='LC_ALL=C.UTF-8 ansible-galaxy'

        # Arm64 specific config
        if [[ $(arch) == "aarch64" ]]
        then
            # Required for VSCode stuff
            # VSCode isn't used on headless non-NixOS systems
            export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1
        fi

        #NixOS specific config
        if grep -q 'ID=nixos' /etc/os-release
        then
          alias sudo="/run/wrappers/bin/sudo $@"
          function nixos-switch {
            git -C ~/opt/nixos-configs pull origin master
            /run/wrappers/bin/sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname) --impure $@
          }
        # All other Linux distros managed with Nix
        else
          function home-switch {
            git -C ~/opt/nixos-configs pull origin master
            nix --extra-experimental-features 'nix-command flakes' run ~/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage --impure $@
          }
        fi
      fi
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

  programs.tiny = {
    enable = true;
  };
}
