{ config, pkgs, home-manager, wezterm-configs, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
in {
  imports = [
    ../firefox/linux.nix
  ];

  home.packages = [
    pkgs._1password-gui
    pkgs.acpi
    pkgs.arch-install-scripts
    pkgs.guake
    pkgs.gnome.gnome-screenshot
    pkgs.inotify-tools
    pkgs.keyutils
    pkgs.libnotify #(notify-send)
    pkgs.nixos-install-tools
    pkgs.nordic
    pkgs.pinentry-rofi
    pkgs.rofi
    pkgs.tailscale
    pkgs.virt-manager
    pkgs.xclip
    pkgs.xdotool
    wezterm-configs.packages.${system}.wezterm
  ];

  home.shellAliases = {
    open = "xdg-open";
    captive-portal = "xdg-open http://$(ip --oneline route get 1.1.1.1 | awk '{print $3}')";
  };

  # Webcord nord config
  home.file.".local/share/applications/webcord-nord.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=Configure WebCord (Nord)
      GenericName=discord
      Comment=Configure WebCord to use Nordic theme
      Exec=webcord --add-css-theme ${homeDir}/.config/WebCord/Themes/nordic.theme.css
      Terminal=false
      Type=Application
      Keywords=webcord;discord;
      Icon=nix-snowflake
      Categories=Utility;
    '';
  };

  # Start 1Password minimized
  home.file.".config/autostart/onepassword.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=1Password
      Exec=1password --silent %U
      Terminal=false
      Type=Application
      Icon=1password
      StartupWMClass=1Password
      Comment=Password manager and secure wallet
      MimeType=x-scheme-handler/onepassword;
      Categories=Office;
    '';
  };

  # Tiny config
  home.file.".config/tiny/config.yml" = {
    enable = true;
    text = ''
      servers:
          - addr: nix-media.tailscale
            port: 6667
            tls: false
            realname: heywoodlh
            nicks: [heywoodlh]
            nickserv_ident:
                command: "op-wrapper.sh item get bitlbee/heywoodlh --fields password"
            join:
                - "&bitlbee"
      defaults:
          nicks: [heywoodlh]
          realname: heywoodlh
          join: []
          tls: false
      log_dir: "/tmp/tiny_logs"
      colors:
          nick: [1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14]
          clear:
              fg: default
              bg: default
          user_msg:
              fg: black
              bg: default
          err_msg:
              fg: black
              bg: maroon
              attrs: [bold]
          topic:
              fg: cyan
              bg: default
              attrs: [bold]
          cursor:
              fg: black
              bg: default
          join:
              fg: lime
              bg: default
              attrs: [bold]
          part:
              fg: maroon
              bg: default
              attrs: [bold]
          nick_change:
              fg: lime
              bg: default
              attrs: [bold]
          faded:
              fg: 242
              bg: default
          exit_dialogue:
              fg: default
              bg: navy
          highlight:
              fg: red
              bg: default
              attrs: [bold]
          completion:
              fg: 84
              bg: default
          timestamp:
              fg: 242
              bg: default
          tab_active:
              fg: default
              bg: default
              attrs: [bold]
          tab_normal:
              fg: gray
              bg: default
          tab_new_msg:
              fg: purple
              bg: default
          tab_highlight:
              fg: red
              bg: default
              attrs: [bold]
    '';
  };




  # Profile
  home.file.".face" = {
    source = builtins.fetchurl {
      url = "https://avatars.githubusercontent.com/u/18178614?v=4";
      sha256 = "sha256:02937kl4qmj29gms9r06kckq8fjpvl40bqi9vpxipwa4xy0wrymg";
    };
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
