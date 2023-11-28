{ config, pkgs, myFlakes, ... }:

let
  system = pkgs.system;
  wezterm = myFlakes.packages.${system}.wezterm;
  homeDir = config.home.homeDirectory;

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
  '';
in {
  home.file.".hammerspoon/init.lua" = {
    text = hammerspoon-lua;
  };
}
