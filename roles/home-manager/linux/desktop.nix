{ config, pkgs, home-manager, myFlakes, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
in {
  imports = [
    ../firefox/linux.nix
  ];

  # Flatpak support
  services.flatpak = {
    enableModule = true;
    target-dir = "${homeDir}/.local/share/flatpak";
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      "gnome-nightly" = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
    };
    packages = [
      #"gnome-nightly:app/org.gnome.Epiphany.Devel//master"
    ];
    postInitCommand = ''
      # Enable extensions in Epiphany
      #${pkgs.flatpak}/bin/flatpak run --user --command=gsettings org.gnome.Epiphany.Devel set org.gnome.Epiphany.web:/org/gnome/epiphany/web/ enable-webextensions true
      # Allow flatpak to see ~/.themes and ~/.icons
      ${pkgs.flatpak}/bin/flatpak override --user --filesystem=${homeDir}/.themes
      ${pkgs.flatpak}/bin/flatpak override --user --filesystem=${homeDir}/.icons
    '';
  };

  # Nix snowflake icon
  home.file.".icons/snowflake.png" = {
    source = builtins.fetchurl {
      url = "https://github.com/NixOS/nixos-artwork/blob/e3a74d1c40086393f2b1b9f218497da2db0ff3ae/logo/white.png?raw=true";
      sha256 = "sha256:0pd45ya86x1z00fb67aqhmmvm7pk50awkmw3bigmhhiwd4lv9n6h";
    };
  };

  home.packages = [
    pkgs._1password-gui
    pkgs.acpi
    pkgs.arch-install-scripts
    pkgs.flatpak
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
      Exec=${pkgs.webcord}/bin/webcord --add-css-theme ${homeDir}/.config/WebCord/Themes/nordic.theme.css
      Terminal=false
      Type=Application
      Keywords=webcord;discord;
      Icon=${homeDir}/.icons/snowflake.png
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
