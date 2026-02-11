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
        default = "heywoodlh";
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
    system.activationScripts.postActivation.text = lib.optionalString (cfg.skhd && config.services.skhd.enable) ''
      # Switch Spotlight to Ctrl + Shift + Space
      /usr/bin/sudo -u ${cfg.user} /usr/bin/defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 64 "
      <dict>
        <key>enabled</key>
        <false/>
        <key>value</key>
        <dict>
          <key>type</key>
          <string>standard</string>
          <key>parameters</key>
            <array>
              <integer>32</integer>
              <integer>49</integer>
              <integer>1048576</integer>
            </array>
        </dict>
      </dict>
      "
      /usr/bin/sudo -u ${cfg.user} /usr/bin/killall cfprefsd
      /usr/bin/sudo /usr/bin/killall mds
      /usr/bin/sudo /usr/bin/mdutil -a -i off
    '';

    services.skhd.skhdConfig = lib.optionalString (cfg.skhd && config.services.skhd.enable) ''
      cmd - space : ${choose-launcher-sh}/bin/choose-launcher.sh
    '';
  };
}
