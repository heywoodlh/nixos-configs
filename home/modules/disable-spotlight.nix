{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.darwin.disable-spotlight;
in {
  options = {
    heywoodlh.home.darwin.disable-spotlight = mkOption {
      default = false;
      description = ''
        Change Spotlight keyboard shortcut to Ctrl + Shift + Space.
        Reboot is required to apply this change. Sometimes doesn't work, change manually if needed.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.activation.disable-spotlight = ''
      # Switch Spotlight to Ctrl + Shift + Space
      /usr/bin/defaults write com.apple.symbolichotkeys.plist AppleSymbolicHotKeys -dict-add 64 "
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
      /usr/bin/killall cfprefsd
    '';
  };
}
