{ config, pkgs, myFlakes, choose-nixpkgs, ... }:

let
  system = pkgs.system;
  wezterm = myFlakes.packages.${system}.wezterm;
  homeDir = config.home.homeDirectory;
  choose = choose-nixpkgs.legacyPackages.${system}.choose-gui;
  choose-launcher-sh = pkgs.writeShellScriptBin "choose-launcher.sh" ''
    application_dirs="/Applications/ /System/Applications/ /System/Library/CoreServices/ /System/Applications/Utilities/"

    if [ -e ''${HOME}/.nix-profile/Applications ]
    then
    	application_dirs="''${application_dirs} ''${HOME}/.nix-profile/Applications"
    fi
    if [ -e ''${HOME}/Applications ]
    then
    	application_dirs="''${application_dirs} ''${HOME}/Applications"
    fi

    selection=$(/bin/ls ''${application_dirs} | /usr/bin/grep -v -E 'Applications/:|Applications:' | /usr/bin/grep '.app' | /usr/bin/sort -u | ${choose}/bin/choose)

    open -a "''${selection}"
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
}
