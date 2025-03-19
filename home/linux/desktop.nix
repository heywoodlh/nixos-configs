{ config, pkgs, home-manager, myFlakes, snowflake, dark-wallpaper, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myWezterm = myFlakes.packages.${system}.wezterm;
  captive-portal = pkgs.writeShellScriptBin "captive-portal" ''
   ${pkgs.xdg-utils}/bin/xdg-open "http://$(${pkgs.iproute2}/bin/ip --oneline route get 1.1.1.1 | ${pkgs.gawk}/bin/awk '{print $3}')"
  '';
  zen-wrapper = pkgs.writeShellScriptBin "zen" ''
    set -ex
    ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || ${pkgs.libnotify}/bin/notify-send "Failed to add flathub repo"
    if ! ${pkgs.flatpak}/bin/flatpak list --user | grep -iq app.zen_browser.zen
    then
      ${pkgs.libnotify}/bin/notify-send "Installing Zen Browser flatpak"
      ${pkgs.flatpak}/bin/flatpak install --noninteractive --user flathub app.zen_browser.zen || ${pkgs.libnotify}/bin/notify-send "Failed to install zen"
      ${pkgs.libnotify}/bin/notify-send "Installed Zen Browser flatpak"
    fi
    ${pkgs.flatpak}/bin/flatpak run --user app.zen_browser.zen || ${pkgs.libnotify}/bin/notify-send "Failed to launch Zen Browser"
  '';
in {
  #imports = [
    #./cosmic-desktop.nix
  #];
  # Flatpak support
  services.flatpak = {
    enableModule = true;
    flatpakDir = "${homeDir}/.local/share/flatpak";
    remotes = {
      "flathub" = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      "flathub-beta" = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
      "gnome-nightly" = "https://nightly.gnome.org/gnome-nightly.flatpakrepo";
    };
    packages = [
      "gnome-nightly:app/org.gnome.Epiphany.Devel//master"
      "flathub:app/io.github.zen_browser.zen//master"
    ];
  };

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
    pkgs.rofi
    pkgs.tailscale
    pkgs.virt-manager
    pkgs.xclip
    pkgs.xdotool
    pkgs.ghostty
    captive-portal
    zen-wrapper
  ] ++ (if system == "aarch64-linux" then [
    myFlakes.packages.aarch64-linux.chromium-widevine
  ] else []);

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

  heywoodlh.home.applications = [
    {
      name = "Zen Browser";
      command = "${zen-wrapper}/bin/zen";
    }
  ];

  # Enable fontconfig
  fonts.fontconfig.enable = true;
}
