{ config, pkgs, nixpkgs-lts, lib, home-manager, myFlakes, light-wallpaper, dark-wallpaper, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myTmux = myFlakes.packages.${system}.tmux;
  myFish = myFlakes.packages.${system}.fish;
  myWezterm = myFlakes.packages.${system}.wezterm;
  gnome-pkgs = nixpkgs-lts.legacyPackages.${system};
in {
  home.packages = with gnome-pkgs; [
    dconf-editor
    gnome-boxes
    gnome-terminal
    gnome-tweaks
    gnomeExtensions.caffeine
    gnomeExtensions.gnome-bedtime
    gnomeExtensions.gsconnect
    gnomeExtensions.hide-cursor
    gnomeExtensions.just-perfection
    gnomeExtensions.night-theme-switcher
    #gnomeExtensions.paperwm
    gnomeExtensions.pop-shell
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.search-light
    pkgs.epiphany
    gnomeExtensions.open-bar
  ];

  # Enable unclutter
  services.unclutter = {
    enable = true;
    timeout = 3;
    extraOptions = [
      "exclude-root"
      "ignore-scrolling"
    ];
  };

  home.file.".config/pop-shell/config.json" = {
    enable = true;
    text = ''
      {
        "float": [
          {
            "class": "1Password"
          },
          {
            "class": "Rustdesk"
          }
        ],
        "skiptaskbarhidden": [],
        "log_on_focus": false
      }
    '';
  };

  # Download wallpaper
  home.file.".wallpaper.png" = {
    source = dark-wallpaper;
  };

  # Epiphany extensions
  home.file."share/epiphany/dark-reader.xpi" = {
    source = builtins.fetchurl {
      url = "https://addons.mozilla.org/firefox/downloads/file/4205543/darkreader-4.9.73.xpi";
      sha256 = "sha256:06lgnfi0azk62b7yzw8znyq955v2iypsy35d1nw6p2314prryfbw";
    };
  };
  home.file."share/epiphany/vim-vixen.xpi" = {
    source = builtins.fetchurl {
      url = "https://addons.mozilla.org/firefox/downloads/file/3845233/vim_vixen-1.2.3.xpi";
      sha256 = "sha256:1dg9m6iwap1xbvw6pa6mhrvaqccjrrb0ns9j38zzspg6r1xcg1lg";
    };
  };
  home.file."share/epiphany/redirector.xpi" = {
    source = builtins.fetchurl {
      url = "https://addons.mozilla.org/firefox/downloads/file/3535009/redirector-3.5.3.xpi";
      sha256 = "sha256:0w8g3kkr0hdnm8hxnhkgxpf0430frzlxkdpcsq5qsx2fjkax7nzd";
    };
  };

  # Epiphany CSS
  home.file.".local/share/epiphany/user-stylesheet.css" = {
    text = ''
      #overview {
        background-color: #3B4252 !important;
        max-width: 100% !important;
        max-height: 100% !important;
        position: fixed !important;
      }

      #overview .overview-title {
        color: white !important;
      }
    '';
  };

  # Now managed by my gnome flake
  # Only Home-Manager-specific settings should live here
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = lib.mkForce "${homeDir}/.wallpaper.png";
      picture-uri-dark = lib.mkForce "${homeDir}/.wallpaper.png";
    };
    #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
    #  binding = lib.mkForce "<Control>grave";
    #  command = lib.mkForce "${pkgs.guake}/bin/guake";
    #  name = lib.mkForce "guake";
    #};
  };
}
