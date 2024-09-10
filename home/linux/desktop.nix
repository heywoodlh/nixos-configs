{ config, pkgs, home-manager, myFlakes, snowflake, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myWezterm = myFlakes.packages.${system}.wezterm;
  browserBin = if system == "aarch64-linux" then "${pkgs.bash}/bin/bash -c 'MESA_GL_VERSION_OVERRIDE=3.3 MESA_GLSL_VERSION_OVERRIDE=330 MESA_GLES_VERSION_OVERRIDE=3.1 MOZ_ENABLE_WAYLAND=1 ${pkgs.firefox}/bin/firefox'" else "${pkgs.mullvad-browser}/bin/mullvad-browser";
in {
  # Flatpak support
  services.flatpak = {
    enableModule = true;
    flatpak-dir = "${homeDir}/.local/share/flatpak";
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      "gnome-nightly" = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
    };
    packages = [
      "flathub:app/io.github.zen_browser.zen/x86_64/stable"
      "gnome-nightly:app/org.gnome.Epiphany.Devel//master"
    ];
  };

  # Nix snowflake icon
  home.file.".icons/snowflake.png" = {
    source = snowflake;
  };

  # Berkeley Mono font installer
  home.file."bin/berkeley-mono-font.sh" = {
    text = ''
      eval $(op signin)
      ${pkgs.curl}/bin/curl 'https://things.heywoodlh.io/berkeley-mono-typeface.zip' -u ":$(op read 'op://Personal/things.heywoodlh.io/password')" -Lo /tmp/berkeley-mono-typeface.zip
      ${pkgs.unzip}/bin/unzip -o /tmp/berkeley-mono-typeface.zip -d /tmp
      mkdir -p ~/.local/share/fonts
      mv /tmp/berkeley-mono/TTF/BerkeleyMono-Regular.ttf ~/.local/share/fonts
      ${pkgs.fontconfig}/bin/fc-cache -vf ~/.local/share/fonts
      rm -rf /tmp/berkeley*
    '';
    executable = true;
  };

  home.packages = [
    pkgs._1password-gui
    pkgs.acpi
    pkgs.arch-install-scripts
    pkgs.flatpak
    pkgs.gnome-screenshot
    pkgs.guake
    pkgs.inotify-tools
    pkgs.jetbrains-mono
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

  # Mullvad desktop file
  home.file.".local/share/applications/mullvad-browser.desktop" = {
    enable = true;
    text = ''
      [Desktop Entry]
      Name=Mullvad Browser
      GenericName=browser
      Comment=Browse the web
      Exec=${browserBin}
      Terminal=false
      Type=Application
      Keywords=browser;internet;
      Icon=${snowflake}
      Categories=Utility;
    '';
  };

  home.file.".local/share/applications/chromium-browser.desktop" = {
    enable = system == "aarch64-linux";
    text = ''
      [Desktop Entry]
      Name=Chromium
      GenericName=browser
      Comment=Chromium browser with Widevine
      Exec=${myFlakes.packages.aarch64-linux.chromium-widevine}/bin/chromium
      Terminal=false
      Type=Application
      Keywords=browser;internet;
      Icon=${snowflake}
      Categories=Utility;
    '';
  };

  # 1Password GUI settings
  # Updated Sept. 10, 2024
  home.file.".config/1Password/settings/settings.json" = {
    text = ''
      {
        "version": 1,
        "sshAgent.enabled": true,
        "developers.cliSharedLockState.enabled": true,
        "app.keepInTray": true,
        "security.authenticatedUnlock.enabled": true,
        "browsers.extension.enabled": true,
        "authTags": {
          "app.keepInTray": "dEgsSYYRe6HRJBb3Yt70XkKSGrO7QW/qsDy78zrmvv0",
          "browsers.extension.enabled": "MaBrlHeABV9gub1TCmOPx72JzyBqiyNGMnLx1/YMw/8",
          "developers.cliSharedLockState.enabled": "VaG8Ag8PnQcqreE4U4pl9jhfJ03BFxl/M1mcA44/bmg",
          "security.authenticatedUnlock.enabled": "BfvCuyEH1oH5/jIl7MNisrJ0nWjlLTGM4rGA9pF95Cg",
          "sshAgent.enabled": "foKNdypQUDimc/DcKt5mUeg2lhd6e5vlS8V8zf1ZU1g"
        }
      }
    '';
  };

  # Enable fontconfig
  fonts.fontconfig.enable = true;
}
