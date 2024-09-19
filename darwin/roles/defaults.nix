{ config, pkgs, myFlakes, ... }:

let
  system = pkgs.system;
in {
  #package config
  nixpkgs.config.allowUnfree = true;
  # nix configuration
  nix = {
    settings = {
      trusted-users = [
        "@admin"
      ];
    };
    linux-builder = {
      enable = true;
      package = pkgs.darwin.linux-builder;
      ephemeral = true; # Wipe on every reboot
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
  fonts.packages = with pkgs; [
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
      mineffect = "scale";
      launchanim = false;
      show-process-indicators = true;
      tilesize = 48;
      static-only = true;
      mru-spaces = false; # disable automatic rearrangement of spaces
      show-recents = false; # disable recents
    };
    finder = {
      AppleShowAllExtensions = true; # show all file extensions
      AppleShowAllFiles = true; # show hidden files
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = false; # disable desktop icons
      ShowPathbar = true; # show breadcrumb path bar
      FXPreferredViewStyle = "Nlsv"; # use list view
    };
    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false; # Disable three finger drag
      Dragging = true;
    };
    # Apple firewall config:
    alf = {
      globalstate = 0; #Disabled until https://www.reddit.com/r/MacOS/comments/1fihlge/comment/lnngp9n
      loggingenabled = 0;
      stealthenabled = 0; #Disabled until https://www.reddit.com/r/MacOS/comments/1fihlge/comment/lnngp9n
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
      NSWindowResizeTime = 0.001;
      NSAutomaticWindowAnimationsEnabled = false;
      NSTableViewDefaultSizeMode = 1; # small icons in finder
      NSDocumentSaveNewDocumentsToCloud = false; # disable saving to iCloud by default
      "com.apple.sound.beep.volume" = 0.000; # mute beep
      AppleICUForce24HourTime = true; # use 24 hour time
    };
    CustomUserPreferences = {
      "NSGlobalDomain" = {
        "AppleSpacesSwitchOnActivate" = 1; # Automatically refocus spaces on app switch
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
}
