{ config, lib, pkgs, ... }:

# For whatever reason, home-manager and nix-darwin modules don't apply defaults settings?
with lib;

let
  cfg = config.heywoodlh.home.darwin.defaults;
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
in {
  options = {
    heywoodlh.home.darwin.defaults = {
      enable = mkOption {
        default = false;
        description = ''
          Configure MacOS defaults.
        '';
        type = types.bool;
      };
      ux = mkOption {
        default = true;
        description = ''
          Configure MacOS defaults for a better UX.
        '';
        type = types.bool;
      };
      privacy = mkOption {
        default = true;
        description = ''
          Configure MacOS defaults for better privacy.
        '';
        type = types.bool;
      };
      security = mkOption {
        default = true;
        description = ''
          Configure MacOS defaults for better security.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    # Helpful resources:
    # - https://github.com/kentcdodds/dotfiles/blob/1e59ac84911eee898b3b9ceab904df9ad243fdd4/.macos#L674
    # - https://macos-defaults.com, specifically checkout the `diff.sh` script in the repo:
    #   - https://github.com/yannbertrand/macos-defaults/blob/main/diff.sh
    home.activation.defaults-ux = mkIf cfg.ux ''
      echo "Applying MacOS defaults UX settings"
      # Enable caching
      /usr/bin/defaults -currentHost write com.apple.applicationaccess allowContentCaching -int 1

      # Show file extensions in Finder
      /usr/bin/defaults -currentHost write NSGlobalDomain "AppleShowAllExtensions" -int "1"
      # Prefer list view in Finder
      /usr/bin/defaults -currentHost write com.apple.finder "FXPreferredViewStyle" -string "Nlsv"
      # Disable file extension warning
      /usr/bin/defaults -currentHost write com.apple.finder "FXEnableExtensionChangeWarning" -bool "false"

      # Disable saving to iCloud by default
      /usr/bin/defaults -currentHost write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

      # Disable the “Are you sure you want to open this application?” dialog
      /usr/bin/defaults -currentHost write com.apple.LaunchServices LSQuarantine -bool false

      # Disable all Spotlight suggestions except for apps and settings
      /usr/bin/defaults -currentHost write com.apple.spotlight orderedItems -array \
        '{"enabled" = 1;"name" = "APPLICATIONS";}' \
        '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
        '{"enabled" = 0;"name" = "DIRECTORIES";}' \
        '{"enabled" = 0;"name" = "PDF";}' \
        '{"enabled" = 0;"name" = "FONTS";}' \
        '{"enabled" = 0;"name" = "DOCUMENTS";}' \
        '{"enabled" = 0;"name" = "MESSAGES";}' \
        '{"enabled" = 0;"name" = "CONTACT";}' \
        '{"enabled" = 0;"name" = "EVENT_TODO";}' \
        '{"enabled" = 0;"name" = "IMAGES";}' \
        '{"enabled" = 0;"name" = "BOOKMARKS";}' \
        '{"enabled" = 0;"name" = "MUSIC";}' \
        '{"enabled" = 0;"name" = "MOVIES";}' \
        '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
        '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
        '{"enabled" = 0;"name" = "SOURCE";}' \
        '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
        '{"enabled" = 0;"name" = "MENU_OTHER";}' \
        '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
        '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
        '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
        '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}' \
        '{"enabled" = 0;"name" = "TIPS";}'

      # Disable auto capitalization
      /usr/bin/defaults -currentHost write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

      # Disable auto correct
      /usr/bin/defaults -currentHost write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

      # Disable dash, period, smart quotes substitution
      /usr/bin/defaults -currentHost write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
      /usr/bin/defaults -currentHost write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
      /usr/bin/defaults -currentHost write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

      # Allow quitting Finder via ⌘ + Q; doing so will also hide desktop icons
      /usr/bin/defaults -currentHost write com.apple.finder QuitMenuItem -bool true

      # Set home directory as default path in Finder
      /usr/bin/defaults -currentHost write com.apple.finder NewWindowTargetPath -string "file://${homeDir}"

      # Use PNG for screenshot format
      /usr/bin/defaults -currentHost write com.apple.screencapture type -string "png"

      # Use CMD + Shift + s to take screenshot area to clipboard
      /usr/bin/defaults -currentHost write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 31 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>115</integer><integer>1</integer><integer>1179648</integer></array><key>type</key><string>standard</string></dict></dict>"

      # Use CMD + [ and CMD + ] to navigate between spaces
      # Disabled because this is seemingly unreliable
      #/usr/bin/defaults -currentHost write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>91</integer><integer>33</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>"
      #/usr/bin/defaults -currentHost write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 80 "<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>91</integer><integer>33</integer><integer>1179648</integer></array><key>type</key><string>standard</string></dict></dict>"

      # Prevent iTunes from launching when pressing the media keys on the keyboard
      /bin/launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist &> /dev/null || true

      # Disable the warning before emptying the Trash
      /usr/bin/defaults -currentHost write com.apple.finder WarnOnEmptyTrash -bool false

      # Restart Finder
      /usr/bin/killall Finder &>/dev/null || true

      # Restart preferences daemon
      /usr/bin/killall cfprefsd &>/dev/null || true
    '';
    home.activation.defaults-privacy = mkIf cfg.privacy ''
      echo "Applying MacOS defaults privacy settings"

      # Disable Apple personalized advertising
      /usr/bin/defaults -currentHost write com.apple.AdLib forceLimitAdTracking -int 1
      /usr/bin/defaults -currentHost write com.apple.AdLib allowApplePersonalizedAdvertising -int 0
      /usr/bin/defaults -currentHost write com.apple.AdLib allowIdentifierForAdvertising -int 0

      # Disable Apple Intelligence (may require restart)
      /usr/bin/defaults -currentHost write com.apple.CloudSubscriptionFeatures.optIn "545129924" -bool "false"
      /usr/bin/defaults -currentHost write com.apple.CloudSubscriptionFeatures.optIn "1341174415" -bool "false"
      /usr/bin/defaults -currentHost write com.apple.CloudSubscriptionFeatures.optIn "device" -bool "false"
      /usr/bin/defaults -currentHost write com.apple.CloudSubscriptionFeatures.optIn "auto_opt_in" -bool "false"
      # Disable Apple Intelligence Report
      /usr/bin/defaults -currentHost write com.apple.AppleIntelligenceReport "reportDuration" -int 0

      # Disable Siri
      /usr/bin/defaults -currentHost write com.apple.assistant.support "Assistant Enabled" -bool false
      /usr/bin/defaults -currentHost write com.apple.Siri StatusMenuVisible -bool false

      # Disable Spotlight search reporting
      /usr/bin/defaults -currentHost write com.apple.assistant.support "Search Queries Data Sharing Status" -int 2

      # Disable the crash reporter
      /usr/bin/defaults -currentHost write com.apple.CrashReporter DialogType -string "none"
    '';
    home.activation.defaults-security = mkIf cfg.security ''
      echo "Applying MacOS defaults privacy settings"
      # Automatic updates (Deprecated, but we'll still set them anyway)
      /usr/bin/defaults -currentHost write com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1
      /usr/bin/defaults -currentHost write com.apple.SoftwareUpdate AutomaticallyInstallAppUpdates -int 1
      /usr/bin/defaults -currentHost write com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -int 1
      /usr/bin/defaults -currentHost write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

      # Disable automatic login
      /usr/bin/defaults -currentHost write com.apple.loginwindow DisableFDEAutoLogin -int 1

      # Date/time sync
      /usr/bin/defaults -currentHost write com.apple.applicationaccess forceAutomaticDateAndTime -int 1

      # Require password on screensaver
      /usr/bin/defaults -currentHost write com.apple.screensaver askForPassword -int 1
      /usr/bin/defaults -currentHost write com.apple.screensaver askForPasswordDelay -int 0

      # Disable guest access
      /usr/bin/defaults -currentHost write com.apple.MCX DisableGuestAccount -int 1
      /usr/bin/defaults -currentHost write com.apple.MCX forceInternetSharingOff -int 1
      /usr/bin/defaults -currentHost write com.apple.AppleFileServer guestAccess -int 0

      # Enable Secure Keyboard Entry
      /usr/bin/defaults -currentHost write com.apple.Terminal SecureKeyboardEntry -int 1
    '';
  };
}
