{ config, pkgs, home-manager, ... }:

{
  imports = [
    ../firefox/linux.nix
  ];

  home.packages = with pkgs; [
    _1password-gui
    acpi
    arch-install-scripts
    guake
    gnome.gnome-screenshot
    inotify-tools
    keyutils
    libnotify #(notify-send)
    nixos-install-tools
    nordic
    pinentry-rofi
    rofi
    tailscale
    virt-manager
    xclip
    xdotool
  ];

  home.shellAliases = {
    open = "xdg-open";
  };

  # Profile
  home.file.".face" = {
    source = builtins.fetchurl {
      url = "https://avatars.githubusercontent.com/u/18178614?v=4";
      sha256 = "sha256:02937kl4qmj29gms9r06kckq8fjpvl40bqi9vpxipwa4xy0wrymg";
    };
  };

  # Rofi config
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

  # 1Password GUI settings
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
        "keybinds.quickAccess": "",
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
}
