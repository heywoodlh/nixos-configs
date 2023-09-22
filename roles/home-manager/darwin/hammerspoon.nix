{ config, pkgs, wezterm-configs, ... }:

let
  system = pkgs.system;
  wezterm = wezterm-configs.packages.${system}.wezterm;

  paperwm.spoon = pkgs.fetchFromGitHub {
    owner = "mogenson";
    repo = "PaperWM.spoon";
    rev = "7c15e00b01177b70f288eef2fe5d41855f0da96e";
    hash = "sha256-NdzdvJNv3ynz1P6SdfTycgbF1PBT3nYMEJacFMt8KFQ=";
  };

  hammerspoon-lua = ''
    PaperWM = hs.loadSpoon("PaperWM")
    PaperWM:bindHotkeys({
        -- switch to a new focused window in tiled grid
        focus_left  = {{"cmd"}, "["},
        focus_right = {{"cmd"}, "]"},
        focus_up    = {{"ctrl", "alt", "cmd"}, "up"},
        focus_down  = {{"ctrl", "alt", "cmd"}, "down"},

        -- move windows around in tiled grid
        swap_left  = {{"cmd", "shift"}, "["},
        swap_right = {{"cmd", "shift"}, "]"},
        swap_up    = {{"ctrl", "alt", "cmd", "shift"}, "up"},
        swap_down  = {{"ctrl", "alt", "cmd", "shift"}, "down"},

        -- position and resize focused window
        center_window = {{"ctrl", "alt", "cmd"}, "c"},
        full_width    = {{"cmd"}, "i"},
        cycle_width   = {{"ctrl", "alt", "cmd"}, "r"},
        cycle_height  = {{"ctrl", "alt", "cmd", "shift"}, "r"},

        -- move focused window into / out of a column
        slurp_in = {{"ctrl", "alt", "cmd"}, "i"},
        barf_out = {{"ctrl", "alt", "cmd"}, "o"},

        -- switch to a new Mission Control space
        switch_space_1 = {{"cmd"}, "1"},
        switch_space_2 = {{"cmd"}, "2"},
        switch_space_3 = {{"cmd"}, "3"},
        switch_space_4 = {{"cmd"}, "4"},
        switch_space_5 = {{"cmd"}, "5"},
        switch_space_6 = {{"cmd"}, "6"},
        switch_space_7 = {{"cmd"}, "7"},
        switch_space_8 = {{"cmd"}, "8"},
        switch_space_9 = {{"cmd"}, "9"},

        -- move focused window to a new space and tile
        move_window_1 = {{"ctrl", "alt", "cmd", "shift"}, "1"},
        move_window_2 = {{"ctrl", "alt", "cmd", "shift"}, "2"},
        move_window_3 = {{"ctrl", "alt", "cmd", "shift"}, "3"},
        move_window_4 = {{"ctrl", "alt", "cmd", "shift"}, "4"},
        move_window_5 = {{"ctrl", "alt", "cmd", "shift"}, "5"},
        move_window_6 = {{"ctrl", "alt", "cmd", "shift"}, "6"},
        move_window_7 = {{"ctrl", "alt", "cmd", "shift"}, "7"},
        move_window_8 = {{"ctrl", "alt", "cmd", "shift"}, "8"},
        move_window_9 = {{"ctrl", "alt", "cmd", "shift"}, "9"}
    })
    PaperWM.window_filter = PaperWM.window_filter:setAppFilter("${wezterm}/bin/wezterm", true)
    PaperWM.window_filter = PaperWM.window_filter:setAppFilter("Finder", false)
    PaperWM:start()

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
  '';
in {
  home.file.".hammerspoon/init.lua" = {
    text = hammerspoon-lua;
  };

  home.file.".hammerspoon/Spoons/PaperWM.spoon" = {
    source = paperwm.spoon;
  };
}
