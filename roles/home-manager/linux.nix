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
    _1password-gui
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
    pinentry-rofi
    rofi
    virt-manager
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

  home.file.".gnupg/gpg-agent.conf" = {
    text = ''
      pinentry-program ${pkgs.pinentry-rofi}/bin/pinentry-rofi
    '';
  };
  home.file.".config/1Password/settings/settings.json" = {
    text = ''
      {
        "version": 1,
        "ui.routes.lastUsedRoute": "{\"type\":\"ItemDetail\",\"content\":{\"itemListRoute\":{\"unlockedRoute\":{\"collectionUuid\":\"UTCG7LWIBNC7LHEM5OSPMN7J64\"},\"itemListType\":{\"type\":\"Category\",\"content\":\"114\"},\"category\":null,\"sortBehavior\":null},\"itemId\":\"1CB\"}}",
        "security.authenticatedUnlock.enabled": true,
        "sshAgent.storeKeyTitles": true,
        "sshAgent.storeSshKeyTitlesResponseGiven": true,
        "sshAgent.enabled": true,
        "keybinds.open": "",
        "keybinds.quickAccess": "CommandOrControl+Meta+[s]S",
        "app.theme": "dark",
        "appearance.interfaceDensity": "compact",
        "developers.cliSharedLockState.enabled": true,
        "app.useHardwareAcceleration": true,
        "authTags": {
          "app.useHardwareAcceleration": "QroNuMzaoNSAt92MMVg6Od7R1nRiyKx+yNsJjrkITy0",
          "developers.cliSharedLockState.enabled": "BENLWIG69/EFYJWyUrsTvfcCGGi6VZpT/pCsbt1fIdE",
          "keybinds.open": "J2ZIPrxfDVulvqV10I0DSxDAeCeKdPrnA8VN5QQhccQ",
          "keybinds.quickAccess": "DrO+203uZNRbp50aXYKsA9HUEKj6lLKwlmS1+uR8YS8",
          "security.authenticatedUnlock.enabled": "af75cCzvjtC4tmat7GMO3X8gw7EGbMzF1A9iNVTzlNg",
          "sshAgent.enabled": "BnZKtIeW3NcF4eo/9EvXSP4drNb8HYijf5PL2tK4SXA",
          "sshAgent.storeKeyTitles": "fuN25iiDAt1/G7H2KFgu+3Yi+38WWWrz1ZEtiysgyVk",
          "sshAgent.storeSshKeyTitlesResponseGiven": "Q4RomTjUe69OBCBWnyZD0St1F3psDo/+u/GX9hfoF8I",
          "ui.routes.lastUsedRoute": "8XGr1Jjakozu4u73yri5yQEvNvtQhc0hxnqn3fZP2O4"
          }
      }'';
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
        program = "/home/heywoodlh/.nix-profile/bin/op-ssh-sign";
      };
      commit = {
        gpgsign = "true";
      };
    };
  };

  programs.zsh = {
    initExtra = ''
      # Linux specific config
      if [[ $(uname) == 'Linux' ]]
      then
        PINENTRY_PROGRAM="${pkgs.pinentry-rofi}/bin/pinentry-rofi"
        alias pbcopy='xclip -selection clipboard'

        function toon {
          echo -n ""
        }

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
