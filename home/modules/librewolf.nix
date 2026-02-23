{ config, lib, pkgs, nur, ... }:

with lib;

let
  cfg = config.heywoodlh.home.librewolf;
  nur-pkgs = import nur {
    inherit pkgs;
    nurpkgs = pkgs;
  };
  socksType = types.submodule {
    options = {
      proxy = mkOption {
        default = null;
        description = ''
          SOCKS proxy address.
        '';
        type = types.nullOr types.str;
      };
      port = mkOption {
        default = 1080;
        description = ''
          SOCKS proxy port.
        '';
        type = types.int;
      };
      noproxy = mkOption {
        default = "localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10,.ts.net,.svc.cluster.local";
        description = ''
          SOCKS proxy no proxy string.
        '';
        type = types.nullOr types.str;
      };
    };
  };
in {
  options = {
    heywoodlh.home.librewolf = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh LibreWolf configuration.
        '';
        type = types.bool;
      };
      default = mkOption {
        default = true;
        description = ''
          Make default browser.
        '';
        type = types.bool;
      };
      search = mkOption {
        default = "duckduckgo";
        description = ''
          Search engine to use in non-private windows -- DDG is default for private.
        '';
        type = types.str;
      };
      socks = mkOption {
        description = "User for heywoodlh configuration.";
        type = socksType;
      };
    };
  };

  config = mkIf cfg.enable {
    home.file."Applications/LibreWolf.app" = {
      enable = pkgs.stdenv.isDarwin;
      source = "${pkgs.librewolf}/Applications/LibreWolf.app";
    };

    home.activation.make-default-browser = if pkgs.stdenv.isDarwin then ''
      /usr/bin/osascript <<-AS
        do shell script "${pkgs.defaultbrowser}/bin/defaultbrowser librewolf"
        try
          tell application "System Events"
            tell application process "CoreServicesUIAgent"
              tell window 1
                tell (first button whose name starts with "use")
                  perform action "AXPress"
                end tell
              end tell
            end tell
          end tell
        end try
      AS
    '' else ''
      ${pkgs.xdg-utils}/bin/xdg-settings set default-web-browser librewolf.desktop || true # may not be present on first setup
    '';

    programs.librewolf = {
      enable = true;

      profiles.home-manager = {
        isDefault = true;
        name = "home-manager";
        bookmarks = {
          force = true;
          settings = [
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
        };
        search = {
          force = true; # This is required so the build won't fail each time
          default = cfg.search;
          privateDefault = "duckduckgo";
          engines = {
            "kagi" = {
              urls = [{ template = "https://kagi.com/search?q={searchTerms}"; }];
              definedaliases = [ "@k" ];
              icon = "https://kagi.com/favicon.ico";
              updateinterval = 24 * 60 * 60 * 1000; # every day
            };
          };
        };
        extensions.packages = with nur-pkgs.repos.rycee.firefox-addons; [
          darkreader
          facebook-container
          kristofferhagen-nord-theme
          multi-account-containers
          #mullvad # https://github.com/nix-community/nur-combined/blob/0b1bfae0cf152df7a77fe9f56beccf7fa450003e/repos/rycee/pkgs/firefox-addons/default.nix#L93-L107
          #onepassword-password-manager <- install via Firefox extensions, seems to break when using nixpkgs' provided app
          privacy-badger
          terms-of-service-didnt-read
          ublock-origin
          vimium
        ];
        settings = {
          "browser.compactmode.show" = true; # enable compact bar
          "browser.theme.content-theme" = 0; # dark mode
          "extensions.activeThemeID" = "{e410fec2-1cbd-4098-9944-e21e708418af}"; # Nord theme
          "toolkit.legacyUserProfileCustomizations.stylesheets" = false; # userChrome.css
          "gfx.webrender.all" = true;
          "browser.startup.page" = 3; # restore previous session
          "extensions.autoDisableScopes" = 0; # enable auto-loading of extensions
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
          "browser.urlbar.suggest.history" = true;
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
          "sidebar.verticalTabs" = true;
          "sidebar.revamp" = true;
          "sidebar.visibility" = "expand-on-hover";
          "sidebar.backupState" = {
            "panelOpen" = true;
            "launcherWidth" = 35;
            "launcherExpanded" = false;
            "launcherVisible" = true;
          };
          "sidebar.main.tools" = "";
          "sidebar.position_start" = true;
          "browser.newtabpage.activity-stream.showWeather" = false;
          "browser.toolbars.bookmarks.visibility" = "never"; # never show bookmarks bar
          # Librewolf specific: preserve logins between app launch
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
          "privacy.sanitize.pending" = "[]";
          # Disable resist fingerprinting for dark mode, WebGL
          "privacy.resistFingerprinting" = false;
          "webgl.disabled" = false;
          # Allow unrestricted copy/paste (i.e. fix issues with webtop)
          "dom.events.asyncClipboard.readText" = false;
        } // lib.optionalAttrs (cfg.socks.proxy != null) {
          "network.proxy.no_proxies_on" = cfg.socks.noproxy;
          "network.proxy.socks" = cfg.socks.proxy;
          "network.proxy.socks_port" = cfg.socks.port;
        };
      };
    };
  };
}
