{ config, pkgs, home-manager, nur, mullvad-browser-home-manager, myFlakes, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  #browser = if system == "aarch64-linux" then "firefox" else "mullvad-browser";
  browser = "firefox";
  noproxies = "localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10,.ts.net";
  socksProxy = "nix-nvidia.barn-banana.ts.net";
  socksPort = 1080;
  common-firefox-settings = {
    # Settings in all Firefox derivatives
    "browser.compactmode.show" = true; # enable compact bar
    "browser.theme.content-theme" = 2; # don't use system theme
    "extensions.activeThemeID" = "{e410fec2-1cbd-4098-9944-e21e708418af}"; # Nord theme
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true; # userChrome.css
    "network.proxy.no_proxies_on" = noproxies;
    "network.proxy.socks" = socksProxy;
    "network.proxy.socks_port" = socksPort;
    "gfx.webrender.all" = true;
  };
  firefox-settings = if browser == "mullvad-browser"  then {
    # Mullvad Browser settings
    "browser.privatebrowsing.autostart" = false; # don't start in private mode
    "privacy.history.custom" = false; # remember history
  } else {
    # Firefox settings
    "app.shield.optoutstudies.enabled" = false;
    "browser.bookmarks.restore_default_bookmarks" = false;
    "browser.bookmarks.showMobileBookmarks" = false;
    "browser.formfill.enable" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = false;
    "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts.havePinned" = "duckduckgo";
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.ping-centre.telemetry" = false;
    "browser.search.isUS" = true;
    "browser.search.suggest.enabled" = false;
    "browser.tabs.drawInTitlebar" = true;
    "browser.urlbar.quicksuggest.scenario" = "offline";
    "browser.urlbar.suggest.engines" = false;
    "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
    "browser.urlbar.suggest.quicksuggest.sponsored" = false;
    "browser.urlbar.suggest.topsites" = false;
    "experiments.activeExperiment" = false;
    "experiments.enabled" = false;
    "experiments.supported" = false;
    "extensions.formautofill.addresses.enabled" = false;
    "extensions.formautofill.creditCards.enabled" = false;
    "extensions.pocket.enabled" = false;
    "extensions.pocket.showHome" = false;
    "extensions.webextensions.restrictedDomains" = "";
    "datareporting.healthreport.uploadEnabled" = false;
    "datareporting.policy.dataSubmissionEnabled" = false;
    "dom.security.https_only_mode" = false;
    "dom.security.https_only_mode_ever_enabled" = false;
    "dom.security.https_only_mode_ever_enabled_pbm" = false;
    "layers.acceleration.force-enabled" = true;
    "network.allow-experiments" = false;
    "signon.rememberSignons" = false;
    "signon.rememberSignons.visibilityToggle" = false;
    "svg.context-properties.content.enabled" = true;
    "toolkit.telemetry.archive.enabled" = false;
    "toolkit.telemetry.bhrPing.enabled" = false;
    "toolkit.telemetry.coverage.opt-out" = true;
    "toolkit.telemetry.enabled" = false;
    "toolkit.telemetry.firstShutdownPing.enabled" = false;
    "toolkit.telemetry.hybridContent.enabled" = false;
    "toolkit.telemetry.newProfilePing.enabled" = false;
    "toolkit.telemetry.prompted" = 2;
    "toolkit.telemetry.rejected" = true;
    "toolkit.telemetry.reportingpolicy.firstRun" = false;
    "toolkit.telemetry.shutdownPingSender.enabled" = false;
    "toolkit.telemetry.unified" = false;
    "toolkit.telemetry.unifiedIsOptIn" = false;
    "toolkit.telemetry.updatePing.enabled" = false;
    "browser.sessionstore.restore_pinned_tabs_on_demand" = false;
  };
  browser-settings = common-firefox-settings // firefox-settings;
  linuxUserChrome = if pkgs.stdenv.isDarwin then
  ""
  else
  ''
    /* Linux stuff to keep GNOME system theme */
    .titlebar-min {
      appearance: auto !important;
      -moz-default-appearance: -moz-window-button-minimize !important;
    }

    .titlebar-max {
      appearance: auto !important;
      -moz-default-appearance: -moz-window-button-maximize !important;
    }

    .titlebar-restore {
      appearance: auto !important;
      -moz-default-appearance: -moz-window-button-restore !important;
    }

    .titlebar-close {
      appearance: auto !important;
      -moz-default-appearance: -moz-window-button-close !important;
    }

    .titlebar-button{
      list-style-image: none !important;
    }
  '';
  userChrome = ''
    /* * Do not remove the @namespace line -- it's required for correct functioning */
    /* set default namespace to XUL */
    @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

    /* Remove Back button when there's nothing to go Back to */
    #back-button[disabled="true"] { display: none; }

    /* Remove Forward button when there's nothing to go Forward to */
    #forward-button[disabled="true"] { display: none; }

    /* Remove Home button (never use it) */
    #home-button { display: none; }

    .titlebar-spacer {
  	    display: none !important;
    }

    /* Remove import bookmarks button */
    #import-button {
      display: none;
    }

    /* Remove bookmark toolbar */
    toolbarbutton.bookmark-item:not(.subviewbutton) {
      display: none;
    }

    /* Remove whitespace in toolbar */
    #nav-bar toolbarpaletteitem[id^="wrapper-customizableui-special-spring"], #nav-bar toolbarspring {
      display: none;
    }

    /* Hide dumb Firefox View button */
    #firefox-view-button {
      visibility: hidden;
    }

    /* Hide Firefox tab icon */
    .tab-icon-image {
      display: none;
    }
    ${linuxUserChrome}
  '';
  firefox-config = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then
      pkgs.runCommand "firefox-0.0.0" { } "mkdir $out"
    else
      pkgs.firefox.override {
        cfg = {
          enableGnomeExtensions = true;
        };
      }
    ;
    profiles.home-manager = {
      search.force = true; # This is required so the build won't fail each time
      bookmarks = [
        {
          # nixos folder
          name = "nixos";
          bookmarks = [
            {
              name = "nixos configuration options";
              url = "https://search.nixos.org/options?";
            }
            {
              name = "home-manager configuration options";
              url = "https://nix-community.github.io/home-manager/options.xhtml";
            }
            {
              name = "nix-darwin configuration options";
              url = "https://daiderd.com/nix-darwin/manual/index.html#sec-options";
            }
            {
              name = "nix packages";
              url = "https://search.nixos.org/packages";
            }
            {
              name = "nixos discourse";
              url = "https://discourse.nixos.org/";
            }
          ];
        }
      ];
      # View extensions here: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        darkreader
        gnome-shell-integration
        kristofferhagen-nord-theme
        multi-account-containers
        noscript
        onepassword-password-manager
        privacy-badger
        redirector
        ublock-origin
        vimium
      ];
      isDefault = true;
      name = "home-manager";
      search.default = "DuckDuckGo";
      userChrome = userChrome;
      settings = browser-settings;
    };
  };
  vscodeSettingsDir = if pkgs.stdenv.isDarwin then
    "Library/Application Support/Code/User"
  else
    ".config/Code/User";
  vscodeSettings = builtins.readFile myFlakes.packages.${system}.vscode-settings;
in {
  home.packages = [
    pkgs.mdp
  ];

  programs.vscode = {
    enable = true;
    #enableUpdateCheck = false; # do not enable, overrides settings.json
    #enableExtensionUpdateCheck = false; # do not enable, overrides settings.json
    # Should match my vscode flake extension list
    extensions = with pkgs.vscode-extensions; [
      arcticicestudio.nord-visual-studio-code
      coder.coder-remote
      eamodio.gitlens
      github.codespaces
      github.copilot
      jnoortheen.nix-ide
      mkhl.direnv
      ms-azuretools.vscode-docker
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-python.python
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      timonwong.shellcheck
      vscodevim.vim
    ];
    keybindings = [
      {
        key = "ctrl+t";
        command = "workbench.action.terminal.toggleTerminal";
      }
      {
        key = "ctrl+w h";
        command = "workbench.action.focusLeftGroup";
      }
      {
        key = "ctrl+w l";
        command = "workbench.action.focusRightGroup";
      }
      {
        key = "ctrl+w j";
        command = "workbench.action.focusBelowGroup";
      }
      {
        key = "ctrl+w k";
        command = "workbench.action.focusAboveGroup";
      }
      {
        key = "ctrl+w s";
        command = "workbench.action.splitEditorDown";
      }
      {
        key = "ctrl+w v";
        command = "workbench.action.splitEditorRight";
      }
      {
        key = "g a";
        command = "git.stage";
        when = "vim.mode == 'Normal' && !terminalFocus";
      }
      {
        key = "ctrl+w w";
        command = "workbench.action.focusNextPart";
      }
    ];
  };

  home.file."${vscodeSettingsDir}/settings.json" = {
    enable = true;
    text = vscodeSettings;
  };

  # Firefox/Mullvad Browser Browser configuration
  programs.${browser} = firefox-config;
}