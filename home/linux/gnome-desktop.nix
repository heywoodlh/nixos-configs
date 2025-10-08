{ config, pkgs, lib, nixpkgs-stable, nixpkgs-lts, vicinae-nix, home-manager, myFlakes, light-wallpaper, dark-wallpaper, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myFish = myFlakes.packages.${system}.fish;
  myWezterm = myFlakes.packages.${system}.wezterm;
  gnome-pkgs = nixpkgs-lts.legacyPackages.${system};
  myGhostty = myFlakes.packages.${system}.ghostty;
  myGnomeExtensionsInstaller = myFlakes.packages.${system}.gnome-install-extensions;
  vicinaePkg = vicinae-nix.packages.${system}.default;
  myVicinae = myFlakes.packages.${system}.vicinae;
  pkgs-stable = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
in {
  home.packages = with gnome-pkgs; [
    # Fallback to old name if undefined (i.e. on Ubuntu LTS)
    (if (builtins.hasAttr "dconf-editor" gnome-pkgs) then gnome-pkgs.dconf-editor else gnome.dconf-editor)
    (if (builtins.hasAttr "gnome-boxes" gnome-pkgs) then gnome-pkgs.gnome-boxes else gnome.gnome-boxes)
    (if (builtins.hasAttr "gnome-terminal" gnome-pkgs) then gnome-pkgs.gnome-terminal else gnome.gnome-terminal)
    (if (builtins.hasAttr "gnome-tweaks" gnome-pkgs) then gnome-pkgs.gnome-tweaks else gnome.gnome-tweaks)
    pkgs.epiphany
    gnome-extensions-cli
    pkgs-stable.gnomeExtensions.pop-shell
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

  heywoodlh.home.autostart = [
    {
      name = "Vicinae";
      command = "${vicinaePkg}/bin/vicinae server";
    }
    {
      name = "Emote";
      command = "${pkgs.emote}/bin/emote";
    }
  ];

  heywoodlh.home.applications = [
    {
      name = "Emote";
      command = "${pkgs.emote}/bin/emote";
    }
  ];


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
          },
          {
            "class": ".guake-wrapped"
          },
          {
            "class": "emote"
          },
          {
            "title": "Vicinae Launcher"
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

  home.file."Pictures/screenshots/.placeholder.txt" = {
    text = "";
  };

  # Install extensions with gnome-extensions-cli so I have more control
  home.activation.install-gnome-extensions = ''
    ${myGnomeExtensionsInstaller}/bin/gnome-ext-install
  '';

  # Now managed by my gnome flake
  # Only Home-Manager-specific settings should live here
  dconf.settings = {
    "org/gnome/shell".enabled-extensions = [
      "pop-shell@system76.com"
    ];
    "org/gnome/desktop/background" = {
      picture-uri = lib.mkForce "${homeDir}/.wallpaper.png";
      picture-uri-dark = lib.mkForce "${homeDir}/.wallpaper.png";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      binding = lib.mkForce "<Control>grave";
      command = lib.mkForce "${pkgs.guake}/bin/guake";
      name = lib.mkForce "guake";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      command = lib.mkForce "${pkgs.bash}/bin/bash -c \"${pkgs.gnome-screenshot}/bin/gnome-screenshot -acf ${homeDir}/Pictures/screenshots/screenshot-$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H:%M:%S).png\"";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
      binding = lib.mkForce "<Super>space";
      command = lib.mkForce "${myVicinae}/bin/vicinae";
      name = lib.mkForce "launcher";
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
      binding = lib.mkForce "<Control>space";
      command = lib.mkForce "${myVicinae}/bin/vicinae";
      name = lib.mkForce "launcher-2";
    };
  };
}
