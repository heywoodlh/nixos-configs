{ config, pkgs, nixpkgs-stable, myFlakes, dark-wallpaper, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  snowflake = ../../assets/nixos-snowflake.png;
  captive-portal = pkgs.writeShellScriptBin "captive-portal" ''
   ${pkgs.xdg-utils}/bin/xdg-open "http://$(${pkgs.iproute2}/bin/ip --oneline route get 1.1.1.1 | ${pkgs.gawk}/bin/awk '{print $3}')"
  '';
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  # Nix snowflake icon
  home.file.".icons/snowflake.png" = {
    source = snowflake;
  };

  # Nix wallpaper
  home.file."Pictures/wallpaper.png" = {
    source = dark-wallpaper;
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
    pkgs.remmina
    pkgs.rofi
    pkgs.tailscale
    pkgs.virt-manager
    pkgs.xclip
    pkgs.xdotool
    pkgs.ghostty
    pkgs.scrcpy
    captive-portal
    pkgs-stable.rustdesk-flutter
  ] ++ pkgs.lib.optionals (config.heywoodlh.home.onepassword.enable) [
    config.heywoodlh.home.onepassword.package
  ] ++ pkgs.lib.optionals (system == "aarch64-linux") [
    myFlakes.packages.aarch64-linux.chromium-widevine
  ];

  home.shellAliases = {
    open = "xdg-open";
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

  # Chromium widevine for ARM64
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
    enable = false; # unreliable on different distros
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
