{ config, pkgs, ... }:

let
  rofi-nord = pkgs.writeText "nord.rasi" ''
    /**
     * Nordic rofi theme
     * Adapted by undiabler <undiabler@gmail.com>
     *
     * Nord Color palette imported from https://www.nordtheme.com/
     *
     */


    * {
    	nord0: #2e3440;
    	nord1: #3b4252;
    	nord2: #434c5e;
    	nord3: #4c566a;

    	nord4: #d8dee9;
    	nord5: #e5e9f0;
    	nord6: #eceff4;

    	nord7: #8fbcbb;
    	nord8: #88c0d0;
    	nord9: #81a1c1;
    	nord10: #5e81ac;
    	nord11: #bf616a;

    	nord12: #d08770;
    	nord13: #ebcb8b;
    	nord14: #a3be8c;
    	nord15: #b48ead;

        foreground:  @nord9;
        backlight:   #ccffeedd;
        background-color:  transparent;

        highlight:     underline bold #eceff4;

        transparent: rgba(46,52,64,0);
    }

    window {
        location: center;
        anchor:   center;
        transparency: "screenshot";
        padding: 10px;
        border:  0px;
        border-radius: 6px;

        background-color: @transparent;
        spacing: 0;
        children:  [mainbox];
        orientation: horizontal;
    }

    mainbox {
        spacing: 0;
        children: [ inputbar, message, listview ];
    }

    message {
        color: @nord0;
        padding: 5;
        border-color: @foreground;
        border:  0px 2px 2px 2px;
        background-color: @nord7;
    }

    inputbar {
        color: @nord6;
        padding: 11px;
        background-color: #3b4252;

        border: 1px;
        border-radius:  6px 6px 0px 0px;
        border-color: @nord10;
    }

    entry, prompt, case-indicator {
        text-font: inherit;
        text-color:inherit;
    }

    prompt {
        margin: 0px 1em 0em 0em ;
    }

    listview {
        padding: 8px;
        border-radius: 0px 0px 6px 6px;
        border-color: @nord10;
        border: 0px 1px 1px 1px;
        background-color: rgba(46,52,64,0.9);
        dynamic: false;
    }

    element {
        padding: 3px;
        vertical-align: 0.5;
        border-radius: 4px;
        background-color: transparent;
        color: @foreground;
        text-color: rgb(216, 222, 233);
    }

    element selected.normal {
    	background-color: @nord7;
    	text-color: #2e3440;
    }

    element-text, element-icon {
        background-color: inherit;
        text-color:       inherit;
    }

    button {
        padding: 6px;
        color: @foreground;
        horizontal-align: 0.5;

        border: 2px 0px 2px 2px;
        border-radius: 4px 0px 0px 4px;
        border-color: @foreground;
    }

    button selected normal {
        border: 2px 0px 2px 2px;
        border-color: @foreground;
    }
  '';
  rofi-config = pkgs.writeText "config.rasi" ''
    configuration {
        font: "JetBrainsMono Nerd Font Mono 16";
        line-margin: 10;

        display-ssh:    "";
        display-run:    "";
        display-drun:   "";
        display-window: "";
        display-combi:  "";
        show-icons:     true;
    }

    @theme "${rofi-nord}"

    listview {
    	lines: 6;
    	columns: 2;
    }

    window {
    	width: 60%;
    }
  '';
  snowflake = ../../assets/nixos-snowflake.png;
in {
  xfconf.settings = {
    # xfconf-query --channel xfce4-keyboard-shortcuts --list --verbose
    xfce4-keyboard-shortcuts = let
      commandPrefix = "commands/custom/";
      wmPrefix = "xfwm4/custom/";
      defaultWmPrefix = "xfwm4/default/";
    in {
      "${commandPrefix}<Super>l" = "${pkgs.xfce.xfce4-session}/bin/xflock4";
      "${commandPrefix}<Super>e" = "${pkgs.rofimoji}/bin/rofimoji --action clipboard --skin-tone light";
      "${commandPrefix}<Super>space" = "${pkgs.rofi}/bin/rofi -combi-modi window,drun -config ${rofi-config} -show combi";
      "${commandPrefix}<Control>grave" = "${pkgs.guake}/bin/guake-toggle";
      "${commandPrefix}<Control><Super>s" = "${config.heywoodlh.home.onepassword.package}/bin/1password --quick-access";
      "${commandPrefix}<Control><Alt>t" = "${pkgs.gnome-terminal}/bin/gnome-terminal";
      "${wmPrefix}<Super>bracketleft" = "left_workspace_key";
      "${wmPrefix}<Super>bracketright" = "right_workspace_key";
      "${wmPrefix}<Super>Up" = "maximize_window_key";
      "${wmPrefix}<Super>Left" = "tile_left_key";
      "${wmPrefix}<Super>1" = "workspace_1_key";
      "${wmPrefix}<Super>2" = "workspace_2_key";
      "${wmPrefix}<Super>3" = "workspace_3_key";
      "${wmPrefix}<Super>4" = "workspace_4_key";
    };
    # xfconf-query --channel xfce4-session --list --verbose
    xfce4-session = {
      "startup/ssh-agent/enabled" = false;
    };
    # xfconf-query --channel xsettings --list --verbose
    xsettings = {
      "Net/ThemeName" = "Nordic";
      "Net/IconThemeName" = "Nordic";
    };
    # xfconf-query --channel xfce4-desktop --list --verbose
    xfce4-desktop = {
      "desktop-icons/style" = 0; # disable icons
    };
    # xfconf-query --channel xfwm4 --list --verbose
    xfwm4 = {
      "general/use_compositing" = true;
      "general/cycle_workspaces" = true;
    };
    # xfconf-query --channel xfce4-panel --list --verbose
    xfce4-panel = {
      "panels/dark-mode" = true;
      "panels" = [ 1 ];
      "panels/panel-1/length" = 100;
      "panels/panel-1/plugin-ids" = [1 2 3 4 5 6 7 8 9 10 11 12];
      "panels/panel-1/size" = 26;
      "plugins/plugin-1" = "applicationsmenu";
      "plugins/plugin-1/button-icon" = "${snowflake}";
      "plugins/plugin-1/show-button-title" = false;
      "plugins/plugin-2" = "separator";
      "plugins/plugin-2/expand" = false;
      "plugins/plugin-2/style" = 0;
      "plugins/plugin-3" = "tasklist";
      "plugins/plugin-3/grouping" = 1;
      "plugins/plugin-3/show-handle" = false;
      "plugins/plugin-3/show-labels" = false;
      "plugins/plugin-4" = "separator";
      "plugins/plugin-4/expand" = true;
      "plugins/plugin-4/style" = 0;
      "plugins/plugin-5" = "pager";
      "plugins/plugin-5/miniature-view" = true;
      "plugins/plugin-5/rows" = 1;
      "plugins/plugin-5/workspace-scrolling" = true;
      "plugins/plugin-5/wrap-workspaces" = false;
      "plugins/plugin-6" = "separator";
      "plugins/plugin-6/style" = 0;
      "plugins/plugin-7" = "systray";
      "plugins/plugin-7/known-items" = ["chrome_status_icon_1"];
      "plugins/plugin-8" = "separator";
      "plugins/plugin-8/style" = 0;
      "plugins/plugin-9" = "clock";
      "plugins/plugin-9/digital-layout" = 3;
      "plugins/plugin-9/digital-time-font" = "JetBrainsMono Nerd Font Bold 10";
      "plugins/plugin-9/mode" = 2;
      "plugins/plugin-9/tooltip-format" = "%x";
      "plugins/plugin-10" = "power-manager-plugin";
      "plugins/plugin-11" = "separator";
      "plugins/plugin-11/style" = 0;
      "plugins/plugin-12" = "actions";
      "plugins/plugin-12/appearance" = 0;
      "plugins/plugin-12/button-title" = 1;
      "plugins/plugin-12/items" = ["-switch-user" "-separator" "-suspend" "-hibernate" "-hybrid-sleep" "-separator" "-separator" "+logout" "-lock-screen" "-restart" "-shutdown" "-logout-dialog"];
    };
  };
  # Tweaks for speeding up Firefox
  # https://wiki.archlinux.org/title/Firefox/Tweaks
  programs.firefox.profiles.home-manager.settings = {
    "browser.cache.disk.parent_directory" = "/run/user/1000/firefox"; # store cache in RAM, i.e. reset on reboot
    "browser.sessionstore.resume_from_crash" = false; # don't restore from crash (by default, firefox saves state every 15 seconds)
  };
  heywoodlh.home.autostart = [
    {
      name = "1Password";
      command = "${pkgs._1password-gui}/bin/1password --silent";
    }
    {
      name = "Guake";
      command = "${pkgs.guake}/bin/guake --hide";
    }
    {
      name = "Caffeine";
      command = "${pkgs.caffeine-ng}/bin/caffeine";
    }
  ];

  home.packages = with pkgs; [
    caffeine-ng
  ];

  home.activation = {
    restart-xfce-panels = ''
      ${pkgs.busybox}/bin/killall -9 xfce4-panel &>/dev/null || true
    '';
  };
}
