{ config, pkgs, lib, home-manager, ... }:

{
  imports = [
    ./base.nix
    ./firefox/linux.nix
    # GNOME settings
    ./linux/gnome-desktop.nix
  ];
  # So that `nix search` works
  nix = lib.mkForce {
    package = pkgs.nix;
    extraOptions = ''
      extra-experimental-features = nix-command flakes
    '';
  };


  home.packages = with pkgs; [
    acpi
    arch-install-scripts
    guake
    gnome.gnome-screenshot
    home-manager
    inotify-tools
    keyutils
    libnotify #(notify-send)
    nixos-install-tools
    nordic
    pinentry-gnome
    rofi-rbw
    rofi-wayland
    xclip
    xdotool
  ];

  home.file.".config/rofi/config.rasi" = {
    text = ''
      configuration {
          font: "JetBrainsMono Nerd Font Mono 16";
          line-margin: 10;

          display-ssh:    "";
          display-run:    "";
          display-drun:   "";
          display-window: "";
          display-combi:  "";
          show-icons:     true;
      }

      @theme "~/.config/rofi/nord.rasi"

      listview {
      	lines: 6;
      	columns: 2;
      }

      window {
      	width: 60%;
      }
    '';
  };
  home.file.".config/rofi/nord.rasi" = {
    text = ''
      /**
       * Nordic rofi theme
       * Adapted by undiabler <undiabler@gmail.com>
       *
       * Nord Color palette imported from https://www.nordtheme.com/
       *
       */


      * {
      	nord0: #2e3440;
      	nord1: #3b4252;
      	nord2: #434c5e;
      	nord3: #4c566a;

      	nord4: #d8dee9;
      	nord5: #e5e9f0;
      	nord6: #eceff4;

      	nord7: #8fbcbb;
      	nord8: #88c0d0;
      	nord9: #81a1c1;
      	nord10: #5e81ac;
      	nord11: #bf616a;

      	nord12: #d08770;
      	nord13: #ebcb8b;
      	nord14: #a3be8c;
      	nord15: #b48ead;

          foreground:  @nord9;
          backlight:   #ccffeedd;
          background-color:  transparent;

          highlight:     underline bold #eceff4;

          transparent: rgba(46,52,64,0);
      }

      window {
          location: center;
          anchor:   center;
          transparency: "screenshot";
          padding: 10px;
          border:  0px;
          border-radius: 6px;

          background-color: @transparent;
          spacing: 0;
          children:  [mainbox];
          orientation: horizontal;
      }

      mainbox {
          spacing: 0;
          children: [ inputbar, message, listview ];
      }

      message {
          color: @nord0;
          padding: 5;
          border-color: @foreground;
          border:  0px 2px 2px 2px;
          background-color: @nord7;
      }

      inputbar {
          color: @nord6;
          padding: 11px;
          background-color: #3b4252;

          border: 1px;
          border-radius:  6px 6px 0px 0px;
          border-color: @nord10;
      }

      entry, prompt, case-indicator {
          text-font: inherit;
          text-color:inherit;
      }

      prompt {
          margin: 0px 1em 0em 0em ;
      }

      listview {
          padding: 8px;
          border-radius: 0px 0px 6px 6px;
          border-color: @nord10;
          border: 0px 1px 1px 1px;
          background-color: rgba(46,52,64,0.9);
          dynamic: false;
      }

      element {
          padding: 3px;
          vertical-align: 0.5;
          border-radius: 4px;
          background-color: transparent;
          color: @foreground;
          text-color: rgb(216, 222, 233);
      }

      element selected.normal {
      	background-color: @nord7;
      	text-color: #2e3440;
      }

      element-text, element-icon {
          background-color: inherit;
          text-color:       inherit;
      }

      button {
          padding: 6px;
          color: @foreground;
          horizontal-align: 0.5;

          border: 2px 0px 2px 2px;
          border-radius: 4px 0px 0px 4px;
          border-color: @foreground;
      }

      button selected normal {
          border: 2px 0px 2px 2px;
          border-color: @foreground;
      }
    '';
  };

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

  programs.zsh = {
    initExtra = ''
      # Linux specific config
      if [[ $(uname) == 'Linux' ]]
      then
        alias pbcopy='xclip -selection clipboard'

        function toon {
          echo -n ""
        }

        # Ansible fix for https://github.com/NixOS/nixpkgs/issues/223151
        alias ansible='LC_ALL=C.UTF-8 ansible'
        alias ansible-pull='LC_ALL=C.UTF-8 ansible-pull'
        alias ansible-playbook='LC_ALL=C.UTF-8 ansible-playbook'
        alias ansible-operator='LC_ALL=C.UTF-8 ansible-operator'
        alias ansible-galaxy='LC_ALL=C.UTF-8 ansible-galaxy'

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
}
