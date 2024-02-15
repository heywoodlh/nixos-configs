{ config, lib, pkgs, myFlakes, choose-nixpkgs, ... }:

let
  system = pkgs.system;
  wezterm = myFlakes.packages.${system}.wezterm;
  homeDir = config.home.homeDirectory;
  choose = choose-nixpkgs.legacyPackages.${system}.choose-gui;
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

    selection=$(/bin/ls ''${application_dirs} ''${currentPath} | /usr/bin/grep -vE 'Applications/:|Applications:|\:' | /usr/bin/sort -u | ${choose}/bin/choose)

    if echo "''${selection}" | grep -q ".app"
    then
      open -a "''${selection}"
    else
      binary="$(which ''${selection})" && exec ''${binary}
    fi

  '';

  hammerspoon-lua = ''
    -- CLI tools
    require("hs.ipc")

    -- Keyboard shortcuts
    hs.hotkey.bind({"ctrl", "alt"}, "t", function()
        hs.execute("open -a ${wezterm}/bin/wezterm")
    end)

    hs.hotkey.bind({"ctrl", "shift"}, "b", function()
        hs.execute("~/bin/battpop.sh")
    end)

    hs.hotkey.bind({"ctrl", "shift"}, "space", function()
        hs.spotify.playpause()
    end)

    hs.hotkey.bind({"ctrl", "shift"}, "n", function()
        hs.spotify.next()
    end)

    hs.hotkey.bind({"ctrl", "shift"}, "p", function()
        hs.spotify.previous()
    end)

    -- Window management shortcuts
    hs.hotkey.bind({"cmd"}, "y", function()
        hs.execute("zsh -c 'if ${pkgs.yabai}/bin/yabai -m config layout | grep -q bsp; then ${pkgs.yabai}/bin/yabai -m config layout float; else ${pkgs.yabai}/bin/yabai -m config layout bsp; fi'")
    end)

    hs.hotkey.bind({"cmd"}, "space", function()
        hs.execute("${choose-launcher-sh}/bin/choose-launcher.sh")
     end)
  '';
in {
  home.file.".hammerspoon/init.lua" = {
    text = hammerspoon-lua;
  };

  home.file."bin/choose-launcher.sh" = {
    executable = true;
    source = "${choose-launcher-sh}/bin/choose-launcher.sh";
  };

  # Disable hotkeys
  home.activation.disableHotkeys = let
    hotkeys = [
      64 # Spotlight
    ];
    disables = map (key:
      "/usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add ${
        toString key
      } '<dict><key>enabled</key><false/></dict>'") hotkeys;
  in lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Disable hotkeys
    echo >&2 "hotkey suppression..."
    set -e
    ${lib.concatStringsSep "\n" disables}
  '';


}
