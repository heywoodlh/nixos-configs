{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.darwin.choose-launcher;
  choose-launcher-sh = pkgs.writeShellScriptBin "choose-launcher.sh" ''
    application_dirs="/Applications/ /System/Applications/ /System/Library/CoreServices/ /System/Applications/Utilities/"
    PATH="''${HOME}/.nix-profile/bin:''${PATH}"

    if [ -e ''${HOME}/.nix-profile/Applications ]
    then
      application_dirs="''${application_dirs} ''${HOME}/.nix-profile/Applications"
    fi
    if [ -e ''${HOME}/Applications ]
    then
      application_dirs="''${application_dirs} ''${HOME}/Applications"
    fi

    currentPath="$(echo ''${PATH} | /usr/bin/sed 's/:/ /g')"

    selection=$(/bin/ls ''${application_dirs} ''${currentPath} | /usr/bin/grep -vE 'Applications/:|Applications:|\:' | /usr/bin/sort -u | ${pkgs.choose-gui}/bin/choose)

    if echo "''${selection}" | grep -q ".app"
    then
      app_name=$(basename "''${selection}" .app)
      osascript -e "tell application \"''${app_name}\" to activate"
    else
      binary="$(which ''${selection})" && exec ''${binary}
    fi
  '';
in {
  options = {
    heywoodlh.darwin.choose-launcher = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh choose-launcher configuration (offline-only Spotlight replacement).
        '';
        type = types.bool;
      };
      user = mkOption {
        default = "";
        description = ''
          Which user to enable choose-launcher for.
        '';
        type = types.str;
      };
      skhd = mkOption {
        default = true;
        description = ''
          Integrate choose-launcher with SKHD.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      choose-gui
      choose-launcher-sh
    ];

    # Nest in lib.optionalAttrs in case cfg.user is unset
    home-manager.users = lib.optionalAttrs (cfg.skhd && config.services.skhd.enable && cfg.user != "") {
      "${cfg.user}".heywoodlh.home.darwin.disable-spotlight = true;
    };

    services.skhd.skhdConfig = lib.optionalString (cfg.skhd && config.services.skhd.enable) ''
      cmd - space : ${choose-launcher-sh}/bin/choose-launcher.sh
    '';
  };
}
