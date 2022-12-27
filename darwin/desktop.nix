{ config, pkgs, ... }:

let
  user_name = "heywoodlh";
  user_full_name = "Spencer Heywood";
  user_description = "Spencer Heywood";
in {
  #packages.nix
  nix.package = pkgs.nix;
  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [
      "ansible"
      "aerc"
      "argocd"
      "aria2"
      "aws-iam-authenticator"
      "awscli"
      "bandit"
      "bash"
      "buildkit"
      "browserpass"
      "bitwarden-cli"
      "choose-gui"
      "clamav"
      "cliclick"
      "coreutils"
      "curl"
      "dante"
      "dos2unix"
      "ffmpeg"
      "findutils"
      "fzf"
      "gcc"
      "gitleaks"
      "glib"
      "glow"
      "gnupg"
      "gnu-sed"
      "gh"
      "git"
      "go"
      "harfbuzz"
      "hashcat"
      "helm"
      "htop"
      "jailkit"
      "jq"
      "jwt-cli"
      "k9s"
      "kind"
      "kompose"
      "kubectl"
      "lefthook"
      "libolm"
      "lima"
      "m-cli"
      "mas"
      "mosh"
      "neofetch"
      "node"
      "openssl@3"
      "pandoc"
      "pass"
      "pass-otp"
      "pinentry-mac"
      "popeye"
      "pre-commit"
      "proxychains-ng"
      "pwgen"
      "python"
      "ripgrep"
      "screen"
      "speedtest-cli"
      "tarsnap"
      "tcpdump"
      "tfenv"
      "tmux"
      "tor"
      "torsocks"
      "tree"
      "vim"
      "vultr-cli"
      "watch"
      "w3m"
      "weechat"
      "wireguard-go"
      "wireguard-tools"
      "zsh"
    ];
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/core"
      "homebrew/services"
      "vultr/vultr-cli"
      "amar1729/formulae"
      "derailed/k9s"
      "derailed/popeye"
      "colindean/fonts-nonfree"
      "kidonng/malt"
      "mike-engel/jwt-cli"
    ];
    casks = [
      "android-platform-tools"
      "beeper"
      "bitwarden"
      "blockblock"
      "brave-browser"
      "caffeine"
      "cursorcerer"
      "discord"
      "element"
      "docker"
      "firefox"
      "font-iosevka"
      "font-microsoft-office"
      "hiddenbar"
      "iterm2"
      "knockknock"
      "lastpass"
      "lulu"
      "microsoft-teams"
      "moonlight"
      "obs"
      "obsidian"
      "oversight"
      "powershell"
      "ransomwhere"
      "raycast"
      "reikey"
      "rustdesk"
      "screens"
      "secretive"
      "signal"
      "slack"
      "syncthing"
      "tor-browser"
      "tunnelblick"
      "ubersicht"
      "utm"
      "vnc-viewer"
      "zoom"
    ];
    masApps = {
      DaisyDisk = 411643860;
      Vimari = 1480933944;
      "WiFi Explorer" = 494803304;
      "Reeder 5." = 1529448980;
      "Okta Extension App" = 1439967473;
    };
  };
 
  users.users.${user_name} = {
    description = "${user_description}";
    home = "/Users/${user_name}";
    name = "${user_full_name}";
    shell = "/usr/local/bin/pwsh";
    packages = [
      pkgs.gcc
      pkgs.git
      pkgs.gnupg
      pkgs.skhd
      pkgs.wireguard-tools
      pkgs.yabai
    ];
  };


  #mac-config.nix 
  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
  programs.nix-index.enable = true;

  environment.shells = with pkgs; [
    bashInteractive
    zsh
    "/usr/local/bin/zsh"
    "/usr/local/bin/pwsh"
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
  };
  
  #users.nix
  nix.settings.trusted-users = [
    "@admin"
  ];

  #wm.nix
  services.yabai.enable = true;
  services.yabai.package = pkgs.yabai;
  services.yabai.enableScriptingAddition = false;
  services.yabai.extraConfig = ''
    yabai -m config status_bar                   off
    yabai -m config mouse_follows_focus          off
    yabai -m config focus_follows_mouse          on
    yabai -m config window_placement             first_child
    yabai -m config window_topmost               off
    yabai -m config window_opacity               off
    yabai -m config window_opacity_duration      0.0
    yabai -m config window_shadow                on
    yabai -m config window_border                off
    yabai -m config window_border_width          4
    yabai -m config active_window_border_color   0xff775759
    yabai -m config normal_window_border_color   0xff505050
    yabai -m config active_window_opacity        1.0
    yabai -m config normal_window_opacity        0.90
    yabai -m config split_ratio                  0.50
    yabai -m config auto_balance                 off
    yabai -m config mouse_modifier               fn
    yabai -m config mouse_action1                move
    yabai -m config mouse_action2                resize
    
    yabai -m config layout                       bsp
    yabai -m config top_padding                  10
    yabai -m config bottom_padding               10
    yabai -m config left_padding                 20
    yabai -m config right_padding                20
    yabai -m config window_gap                   10

    yabai -m signal --add event=window_destroyed \
      action="''\'''${functions[focus_under_cursor]}"
    yabai -m signal --add event=window_minimized \
      action="''\'''${functions[focus_under_cursor]}"
    yabai -m signal --add event=application_hidden \
      action="''\'''${functions[focus_under_cursor]}"
    
    function focus_under_cursor {
      if yabai -m query --windows --space |
          jq -er 'map(select(.focused == 1)) | length == 0' >/dev/null; then
        yabai -m window --focus mouse 2>/dev/null || true
      fi
    }    

    yabai -m rule --add app="/usr/local/bin/choose" manage=off
    yabai -m rule --add app="/opt/homebrew/bin/choose" manage=off
    yabai -m rule --add app="choose" manage=off
    yabai -m rule --add app="/usr/local/bin/pinentry-mac" manage=off
    yabai -m rule --add app="/opt/homebrew/bin/pinentry-mac" manage=off
    yabai -m rule --add app="pinentry-mac" manage=off
    yabai -m rule --add app="^System Preferences$" manage=off
  '';

  services.skhd.enable = true;
  services.skhd.package =  pkgs.skhd;
  services.skhd.skhdConfig = ''
    
    # focus window
    alt - j : yabai -m window --focus west
    alt - k : yabai -m window --focus south
    alt - i : yabai -m window --focus north
    alt - l : yabai -m window --focus east
    
    # swap window
    shift + alt - j : yabai -m window --swap west
    shift + alt - k : yabai -m window --swap south
    shift + alt - i : yabai -m window --swap north
    shift + alt - l : yabai -m window --swap east
    
    # move window
    shift + cmd - j : yabai -m window --warp west
    shift + cmd - k : yabai -m window --warp south
    shift + cmd - i : yabai -m window --warp north
    shift + cmd - l : yabai -m window --warp east
    
    # balance size of windows
    shift + alt - 0 : yabai -m space --balance
    
    # make floating window fill screen
    shift + alt - up     : yabai -m window --grid 1:1:0:0:1:1
    
    # make floating window fill left-half of screen
    shift + alt - left   : yabai -m window --grid 1:2:0:0:1:1
    
    # make floating window fill right-half of screen
    shift + alt - right  : yabai -m window --grid 1:2:1:0:1:1
    
    # destroy desktop
    cmd + alt - w : yabai -m space --destroy
    
    # fast focus desktop
    cmd + alt - x : yabai -m space --focus recent
    cmd + alt - z : yabai -m space --focus prev
    cmd + alt - c : yabai -m space --focus next
    cmd - 1 : yabai -m space --focus 1
    cmd - 2 : yabai -m space --focus 2
    cmd - 3 : yabai -m space --focus 3
    cmd - 4 : yabai -m space --focus 4
    cmd - 5 : yabai -m space --focus 5
    cmd - 6 : yabai -m space --focus 6
    cmd - 7 : yabai -m space --focus 7
    cmd - 8 : yabai -m space --focus 8
    cmd - 9 : yabai -m space --focus 9
    cmd - 0 : yabai -m space --focus 10
    
    # send window to desktop and follow focus
    shift + cmd - x : yabai -m window --space recent; yabai -m space --focus recent
    shift + cmd - z : yabai -m window --space prev; yabai -m space --focus prev
    shift + cmd - c : yabai -m window --space next; yabai -m space --focus next
    shift + cmd - 1 : yabai -m window --space  1; yabai -m space --focus 1
    shift + cmd - 2 : yabai -m window --space  2; yabai -m space --focus 2
    shift + cmd - 3 : yabai -m window --space  3; yabai -m space --focus 3
    shift + cmd - 4 : yabai -m window --space  4; yabai -m space --focus 4
    shift + cmd - 5 : yabai -m window --space  5; yabai -m space --focus 5
    shift + cmd - 6 : yabai -m window --space  6; yabai -m space --focus 6
    shift + cmd - 7 : yabai -m window --space  7; yabai -m space --focus 7
    shift + cmd - 8 : yabai -m window --space  8; yabai -m space --focus 8
    shift + cmd - 9 : yabai -m window --space  9; yabai -m space --focus 9
    shift + cmd - 0 : yabai -m window --space 10; yabai -m space --focus 10
    
    # focus monitor
    #ctrl + alt - x  : yabai -m display --focus recent
    #ctrl + alt - z  : yabai -m display --focus prev
    #ctrl + alt - c  : yabai -m display --focus next
    #ctrl + alt - 1  : yabai -m display --focus 1
    #ctrl + alt - 2  : yabai -m display --focus 2
    #ctrl + alt - 3  : yabai -m display --focus 3
    
    
    # move window
    shift + ctrl - a : yabai -m window --move rel:-20:0
    shift + ctrl - s : yabai -m window --move rel:0:20
    shift + ctrl - w : yabai -m window --move rel:0:-20
    shift + ctrl - d : yabai -m window --move rel:20:0
    
    # increase window size
    shift + alt - a : yabai -m window --resize left:-20:0
    shift + alt - s : yabai -m window --resize bottom:0:20
    shift + alt - w : yabai -m window --resize top:0:-20
    shift + alt - d : yabai -m window --resize right:20:0
    
    # decrease window size
    #shift + cmd - a : yabai -m window --resize left:20:0
    #shift + cmd - s : yabai -m window --resize bottom:0:-20
    #shift + cmd - w : yabai -m window --resize top:0:20
    #shift + cmd - d : yabai -m window --resize right:-20:0
    
    # set insertion point in focused container
    #ctrl + alt - h : yabai -m window --insert west
    #ctrl + alt - j : yabai -m window --insert south
    #ctrl + alt - k : yabai -m window --insert north
    #ctrl + alt - l : yabai -m window --insert east
    
    # rotate tree
    alt - r : yabai -m space --rotate 90
    
    # mirror tree y-axis
    alt - y : yabai -m space --mirror y-axis
    
    # mirror tree x-axis
    alt - x : yabai -m space --mirror x-axis
    
    # toggle desktop offset
    alt - a : yabai -m space --toggle padding; yabai -m space --toggle gap
    
    # toggle window parent zoom
    alt - d : yabai -m window --toggle zoom-parent
    
    # toggle window fullscreen zoom
    alt - f : yabai -m window --toggle zoom-fullscreen
    
    # toggle window native fullscreen
    shift + alt - f : yabai -m window --toggle native-fullscreen
    
    # toggle window border
    shift + alt - b : yabai -m window --toggle border
    
    # toggle window split type
    alt - e : yabai -m window --toggle split
    
    # float / unfloat window and center on screen
    alt - t : yabai -m window --toggle float;\
              yabai -m window --grid 4:4:1:1:2:2
    
    # toggle sticky (show on all spaces)
    alt - s : yabai -m window --toggle sticky
    
    # toggle topmost (keep above other windows)
    alt - o : yabai -m window --toggle topmost
    
    # toggle sticky, topmost and resize to picture-in-picture size
    alt - p : yabai -m window --toggle sticky;\
              yabai -m window --toggle topmost;\
              yabai -m window --grid 5:5:4:0:1:1
    
    # change layout of desktop
    ctrl + alt - a : yabai -m space --layout bsp
    ctrl + alt - d : yabai -m space --layout float
    
    # Custom stuff
    :: passthrough
    ctrl + cmd - p ; passthrough
    passthrough < ctrl + cmd - p ; default
    
    ctrl + cmd - s : bash -c 'source ~/.bash.d/darwin && pass-choose' 
    
    ctrl + cmd - b : bash -c 'source ~/.bash.d/functions && battpop'
    ctrl + cmd - d : bash -c 'source ~/.bash.d/functions && timepop'
    
    #cmd - space : bash -c "source ~/.bash.d/darwin && choose-launcher" ## Use raycast instead
    cmd - b : bash -c "source ~/.bash.d/darwin && choose-buku"
    cmd + shift - k : bash -c "source ~/.bash.d/darwin && snippets"
    
    #ctrl - 0x29 : bash -c "~/Applications/keynav.app/Contents/MacOS/XEasyMotion"
    
    ## Control mouse with keyboard
    ctrl - k : cliclick "m:+0,-15" #up
    ctrl - j : cliclick "m:+0,+15" #down
    ctrl - l : cliclick "m:+15,+0" #right
    ctrl - h : cliclick "m:-15,+0" #left
    
    ctrl + shift - k : cliclick "m:+0,-80" #up
    ctrl + shift - j : cliclick "m:+0,+80" #down
    ctrl + shift - l : cliclick "m:+80,+0" #right
    ctrl + shift - h : cliclick "m:-80,+0" #left
    
    ctrl - 0x21 : cliclick ku:ctrl c:. # click
    ctrl - 0x1E : cliclick ku:ctrl rc:.  # right click
  '';
}
