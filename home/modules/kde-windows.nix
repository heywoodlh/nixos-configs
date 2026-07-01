{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.home.kde-windows;
  homeDir = config.home.homeDirectory;
  kdeWin11 = pkgs.fetchFromGitHub {
    owner = "yeyushengfan258";
    repo = "Win11OS-kde";
    rev = "9f021c3e71da7baf59a0614ab858d53b1e455fd5";
    hash = "sha256-R1l0YG+UEfFKPJd/pQJ3aJzWKg1ru0gWasW7zStK1Ig=";
  };
in {
  options = {
    heywoodlh.home.kde-windows = {
      enable = mkOption {
        default = false;
        description = ''
          Configure KDE to look like Windows 11.
        '';
        type = bool;
      };
      active = mkOption {
        default = true;
        description = ''
          Set Windows 11 as the default theme.
        '';
        type = bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.activation.kde-windows = ''
      # https://github.com/yeyushengfan258/Win11OS-kde/blob/main/install.sh

      AURORAE_DIR="${homeDir}/.local/share/aurorae/themes"
      SCHEMES_DIR="${homeDir}/.local/share/color-schemes"
      PLASMA_DIR="${homeDir}/.local/share/plasma/desktoptheme"
      LAYOUT_DIR="${homeDir}/.local/share/plasma/layout-templates"
      LOOKFEEL_DIR="${homeDir}/.local/share/plasma/look-and-feel"
      KVANTUM_DIR="${homeDir}/.config/Kvantum"
      WALLPAPER_DIR="${homeDir}/.local/share/wallpapers"

      mkdir -p "$AURORAE_DIR"
      mkdir -p "$SCHEMES_DIR"
      mkdir -p "$PLASMA_DIR"
      mkdir -p "$LOOKFEEL_DIR"
      mkdir -p "$KVANTUM_DIR"
      mkdir -p "$WALLPAPER_DIR"

      find ${homeDir}/.local/share/aurorae -type d -exec chmod 0755 {} \; &>/dev/null
      find ${homeDir}/.local/share/color-schemes -type d -exec chmod 0755 {} \; &>/dev/null
      find ${homeDir}/.local/share/plasma -type d -exec chmod 0755 {} \; &>/dev/null
      find ${homeDir}/.config/Kvantum -type d -exec chmod 0755 {} \; &>/dev/null
      find ${homeDir}/.local/share/wallpapers -type d -exec chmod 0755 {} \; &>/dev/null

      find ${homeDir}/.local/share/aurorae -type f -exec chmod 0644 {} \; &>/dev/null
      find ${homeDir}/.local/share/color-schemes -type f -exec chmod 0644 {} \; &>/dev/null
      find ${homeDir}/.local/share/plasma -type f -exec chmod 0644 {} \; &>/dev/null
      find ${homeDir}/.config/Kvantum -type f -exec chmod 0644 {} \; &>/dev/null
      find ${homeDir}/.local/share/wallpapers -type f -exec chmod 0644 {} \; &>/dev/null

      cp -rf ${kdeWin11}/aurorae/* "$AURORAE_DIR"
      cp -rf ${kdeWin11}/color-schemes/*.colors "$SCHEMES_DIR"
      cp -rf ${kdeWin11}/Kvantum/* "$KVANTUM_DIR"
      cp -rf ${kdeWin11}/plasma/desktoptheme/* "$PLASMA_DIR"
      cp -rf ${kdeWin11}/plasma/look-and-feel/* "$LOOKFEEL_DIR"
      cp -rf ${kdeWin11}/wallpaper/* "$WALLPAPER_DIR"
    '' + lib.optionalString (cfg.active) ''
      ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Win11OS
    '';
  };
}
