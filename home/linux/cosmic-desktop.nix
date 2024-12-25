{ config, pkgs, myFlakes, dark-wallpaper, ... }:

# TODO settings:
# - [x?] autotile
# - [x?] remap caps lock to super
# - [] autohide dock
# - [] change accent color to nord theme (#252a33)
# - [] 24 hr clock
# - [] 4 virtual workspaces
# - [x?] wallpaper
# TODO keyboard shortcuts:
# - [] super+space launcher
# - [] super+]: right workspace
# - [] super+[: left workspace
# - [] ctrl+`: guake
let
  system = pkgs.system;
  myTmux = myFlakes.packages.${system}.tmux;
  myFish = myFlakes.packages.${system}.fish;
in {
  programs.cosmic-term.profiles = [
    {
      command = "${myTmux}/bin/tmux";
      hold = false;
      is_default = true;
      name = "Default";
      syntax_theme_dark = "COSMIC Dark";
      syntax_theme_light = "COSMIC Light";
      tab_title = "Default";
    }
    {
      command = "${myFish}/bin/fish";
      hold = false;
      is_default = false;
      name = "Fish";
      syntax_theme_dark = "COSMIC Dark";
      syntax_theme_light = "COSMIC Light";
      tab_title = "Fish";
    }
  ];
  wayland.desktopManager.cosmic = {
    enable = true;
    configFile = {
      "com.system76.CosmicBackground" = {
        version = 1;
        entries = {
          wallpapers = [
            {
              __type = "tuple";
              value = [
                "Virtual-1"
                {
                  __type = "enum";
                  value = [
                    "${dark-wallpaper}"
                  ];
                  variant = "Path";
                }
              ];
            }
          ];
        };
      };
      "com.system76.CosmicTerm" = {
        version = 1;
        entries = {
          font_name = "JetBrains Mono";
          font_size = 14;
        };
      };
      "com.system76.CosmicComp" = {
        version = 1;
        entries = {
          autotile = true; # enable tiling
          xkb_config = {
            layout = "us";
            options = {
              value = "caps:super";
            };
          };
        };
      };
    };
  };
}
