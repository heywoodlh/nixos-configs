{ config, pkgs, myFlakes, ... }:

let
  system = pkgs.system;
in {
  #package config
  nixpkgs.config.allowUnfree = true;
  # nix configuration
  nix = {
    settings = {
      auto-optimise-store = true;
      trusted-users = [
        "@admin"
      ];
    };
    linux-builder = {
      enable = true;
      package = pkgs.darwin.linux-builder;
    };
  };
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    freshfetch
    zsh
  ];

  environment.systemPackages = [
    myFlakes.packages.${system}.vim
    myFlakes.packages.${system}.git
  ];

  # add nerd fonts
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "Hack" "DroidSansMono" "Iosevka" ]; })
  ];

  #system-defaults.nix
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
      mineffect = "genie";
      launchanim = true;
      show-process-indicators = true;
      tilesize = 48;
      static-only = true;
      mru-spaces = false;
      show-recents = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = false; # disable desktop icons
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
      Dragging = true;
    };
    # Apple firewall config:
    alf = {
      globalstate = 2;
      loggingenabled = 0;
      stealthenabled = 1;
    };
    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # set dark mode
      AppleInterfaceStyleSwitchesAutomatically = false;
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      _HIHideMenuBar = true;
    };
    CustomUserPreferences = {
      "NSGlobalDomain" = {
        "AppleSpacesSwitchOnActivate" = 0; # Do not automatically refocus spaces
      };
      "com.googlecode.iterm2" = {
        "PrefsCustomFolder" = "~/.config/iterm2";
        "LoadPrefsFromCustomFolder" = 1;
      };
      "org.gpgtools.common" = {
        "UseKeychain" = "NO";
        "DisableKeychain" = "yes";
      };
    };
  };
   # Add flake support
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Use touch ID for sudo auth
  security.pam.enableSudoTouchIdAuth = true;
  environment.postBuild = ''
    # Disable Spotlight in favor of Hammerspoon
    # Logout to take effect
    /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
      -c "Delete :AppleSymbolicHotKeys:64" \
      -c "Add :AppleSymbolicHotKeys:64:enabled bool false" \
      -c "Add :AppleSymbolicHotKeys:64:value:parameters array" \
      -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 65535" \
      -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 49" \
      -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 1048576" \
      -c "Add :AppleSymbolicHotKeys:64:type string standard" || true
  '';
}
