# Configuration loaded for family systems
{ config, pkgs, determinate-nix, home-manager, nur, ... }:

let
  system = pkgs.system;
  stdenv = pkgs.stdenv;
  render-bookmarks = pkgs.stdenv.mkDerivation {
    name = "render-bookmarks";
    builder = pkgs.bash;
    args = let
      bookmarks = [
        {
          name = "code.org";
          url = "https://code.org";
        }
        {
          name = "animalia";
          url = "https://animalia.bio";
        }
        {
          name = "wikipedia";
          url = "https://wikipedia.org";
        }
        {
          name = "linux journey";
          url = "https://linuxjourney.com";
        }
        {
          name = "national geographic";
          url = "https://kids.nationalgeographic.com";
        }
        {
          name = "inaturalist";
          url = "https://www.inaturalist.org";
        }
        {
          name = "apple music";
          url = "https://music.apple.com";
        }
        {
          name = "plex";
          url = "https://plex.tv/web";
        }
        {
          name = "coolmathgames";
          url = "https://coolmathgames.com";
        }
        {
          name = "ClassLink";
          url = "https://launchpad.classlink.com/southsanpete#mybackpack";
        }
      ];
      # Render bookmarks with buku
      bookmarksJson = pkgs.writeText "bookmarks.json" (builtins.toJSON bookmarks);
      renderBookmarks = pkgs.writeShellScript "render-bookmarks.sh" ''
        ${pkgs.coreutils}/bin/mkdir -p /tmp/buku
        for url in $(${pkgs.jq}/bin/jq -r '.[] | .url' "${bookmarksJson}")
        do
          # Use select(url == "$url") to get the name
          name=$(${pkgs.jq}/bin/jq -r --arg url "$url" '.[] | select(.url == $url) | .name' "${bookmarksJson}")
          XDG_DATA_HOME=/tmp/buku ${pkgs.buku}/bin/buku --nostdin -a "$url" --title "$name"
        done
        ${pkgs.coreutils}/bin/mkdir -p $out
        XDG_DATA_HOME=/tmp/buku ${pkgs.buku}/bin/buku --export $out/bookmarks.html
        ${pkgs.coreutils}/bin/rm -rf /tmp/buku
      '';
    in [ "${renderBookmarks}" ];
  };
  configureFirefox = let
    profiles-ini = pkgs.writeText "profiles.ini" ''
      [General]
      StartWithLastProfile=1
      Version=2

      [Profile0]
      Default=1
      IsRelative=1
      Name=home-manager
      Path=home-manager
    '';
  in pkgs.writeShellScript "firefox.sh" ''
      mkdir -p $HOME/.mozilla
      mkdir -p $HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/home-manager
      cp -fv ${profiles-ini} $HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/profiles.ini
      for file in $HOME/.mozilla/firefox/home-manager/*
      do
        # Only copy Nix symlinks
        if [[ -L $file ]] && ! echo $file | grep -q lock
        then
          cp -fvL $file $HOME/.var/app/org.mozilla.firefox/.mozilla/firefox/home-manager || true
        fi
      done
      # Disable "normal" firefox
      grep -q 'NoDisplay=true' $HOME/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop || printf "NoDisplay=true\n" >> $HOME/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop
      grep -q 'Hidden=true' $HOME/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop || printf "Hidden=true\n" >> $HOME/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop
      rm -f $HOME/.local/share/flatpak/exports/share/applications/org.mozilla.firefox.desktop &>/dev/null || true
      ${pkgs.desktop-file-utils}/bin/update-desktop-database &>/dev/null || true

      # Cleanup leftovers
      rm -rf $HOME/.mozilla/firefox/home-manager/*.bak &>/dev/null || true

      # Setup bookmarks
      cp -f "${render-bookmarks}/bookmarks.html" $HOME/.var/app/org.mozilla.firefox/bookmarks.html
  '';
in {
  imports = [
    home-manager.nixosModules.home-manager
  ];

  # Create "family" user
  users.users.family = {
    isNormalUser  = true;
    home  = "/home/family";
    description  = "Family";
    extraGroups  = [ "networkmanager" ];
  };

  home-manager = {
    backupFileExtension = ".bak";
    users.family = { ... }: {
      home.stateVersion = "24.11";
      home.activation.flatpak = ''
        echo "Installing Flatpaks..."
        ${pkgs.gnome-software}/bin/gnome-software --quit || true # kill gnome-software so flatpaks show up in search
        ${pkgs.flatpak}/bin/flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub org.mozilla.firefox
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub net.supertuxkart.SuperTuxKart
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub sh.cider.Cider
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub com.obsproject.Studio
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub org.onlyoffice.desktopeditors
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub org.videolan.VLC
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub com.visualstudio.code
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub com.valvesoftware.SteamLink
        ${pkgs.flatpak}/bin/flatpak --user install --noninteractive -y --or-update flathub com.jeffser.Alpaca
        echo "Completed installation of Flatpaks..."
      '';
      home.file.".local/share/applications/org.mozilla.firefox.desktop".text = ''
        [Desktop Entry]
        Name=Firefox
        GenericName=Firefox
        Comment=Browse the web
        Exec=${pkgs.flatpak}/bin/flatpak run org.mozilla.firefox -P home-manager
        Terminal=false
        Type=Application
        Keywords=browser;
        Icon=org.mozilla.firefox
        Categories=Network;
      '';
      home.file.".config/autostart/configure-firefox.desktop".text = ''
        [Desktop Entry]
        Name=Configure Firefox
        GenericName=configure-firefox
        Comment=Configure Firefox
        Exec=${configureFirefox}
        Terminal=false
        Type=Application
        Keywords=browser;
        Icon=org.mozilla.firefox
        Categories=Network;
      '';
      home.packages = with pkgs; [
        ghostty
        msedit
        gnomeExtensions.caffeine
        gnomeExtensions.just-perfection
        gnomeExtensions.search-light
        gnomeExtensions.space-bar
      ];
      dconf.settings = {
        "org.gnome.shell" = {
          enabled-extensions = [ "caffeine@patapon.info" "search-light@icedman.github.com" "just-perfection-desktop@just-perfection" ];
          favorite-apps = ["firefox.desktop" "ghostty.desktop"];
        };
        "org/gnome/shell/extensions/search-light" = {
          background-color = "(0.27058824896812439, 0.27450981736183167, 0.29019609093666077, 0.25)";
          blur-background = "false";
          blur-brightness = "0.59999999999999998";
          blur-sigma = "30.0";
          border-radius = "5.76171875";
          entry-font-size = "1";
          monitor-count = "1";
          preferred-monitor = "0";
          scale-height = "0.10000000000000001";
          scale-width = "0.10000000000000001";
          shortcut-search = ["<Super>space"];
          window-effect = "0";
          window-effect-color = "(0.27058824896812439, 0.27450981736183167, 0.29019609093666077, 1.0)";
        };
      };
      # Firefox configuration
      programs.firefox = {
        enable = true;
        profiles.home-manager = {
          isDefault = true;
          name = "home-manager";
          search = {
            force = false;
            default = "duckduckgo";
            privateDefault = "duckduckgo";
            engines = {
              "duckduckgo" = {
                urls = [{ template = "https://safe.duckduckgo.com/?q={searchTerms}"; }];
                definedAliases = [ "@k" ];
                icon = "https://duckduckgo.com/favicon.ico";
                updateInterval = 24 * 60 * 60 * 1000; # every day
              };
            };
          };
          bookmarks = {
            force = true;
            settings = [];
          };
          settings = {
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
            "network.proxy.no_proxies_on" = "localhost,127.0.0.1,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,100.64.0.0/10,.ts.net,.svc.cluster.local";
            "network.proxy.type" = 1;
            "network.proxy.http" = "localhost";
            "network.proxy.http_port" = 3128;
            "network.proxy.ssl" = "localhost";
            "network.proxy.ssl_port" = 3128;
            "network.proxy.backup.ssl_port" = 3128;
            "browser.bookmarks.file" = "/home/family/.var/app/org.mozilla.firefox/bookmarks.html";
          };
        };
      };
      home.activation.firefox-manage = ''
        ${configureFirefox}
      '';
    };
  };

  users.extraGroups.lp.members = [ "family" ];
  users.extraGroups.scanner.members = [ "family" ];

  # Parental controls
  services.malcontent.enable = true;

  # Flatpak for apps
  services.flatpak.enable = true;
  services.gnome.core-apps.enable = true;

  system.activationScripts.disable-heywoodlh = let
    myConf = pkgs.writeText "heywoodlh" ''
      [User]
      Language=
      XSession=gnome
      SystemAccount=true
    '';
  in ''
    cp -f ${myConf} /var/lib/AccountsService/users/heywoodlh
    printf "Disabled heywoodlh user in GDM, restart GDM to apply changes.\n"
  '';

  # Disable sleep
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      squid = {
        image = "docker.io/heywoodlh/squid:6.13";
        autoStart = true;
        ports = [
          "3128:3128"
        ];
        volumes = let
          squid-conf = pkgs.writeText "squid.conf" ''
            http_port 3128

            append_domain .local
            acl localnet src 192.168.1.0/24
            acl localnet src 100.64.0.0/10

            acl Safe_ports port 80
            acl Safe_ports port 443

            ## Set a specific ACL for a domain (to allow for easy direct connections for some domains)
            acl heywoodlh-io dstdomain .heywoodlh.io
            acl local-domain dstdomain .local
            acl tailscale-dns dstdomain .tailscale
            acl tailscale dst 100.64.0.0/10
            acl nixos-domains dstdomain .nixos.org

            always_direct allow heywoodlh-io
            always_direct allow local-domain
            always_direct allow tailscale-dns
            always_direct allow tailscale
            always_direct allow nixos-domains

            acl allowed_domains dstdomain "/etc/squid/allowed_domains.txt"
            acl allowed_networks dst "/etc/squid/allowed_networks.txt"
            acl CONNECT method CONNECT

            http_access deny !Safe_ports
            http_access allow allowed_domains
            http_access allow allowed_networks
            http_access deny !allowed_networks
            http_access allow localhost manager
            http_access deny manager

            http_access allow localnet
            http_access deny all

            coredump_dir /var/spool/squid

            refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
            refresh_pattern (Release|Packages(.gz)*)$      0       20%     2880
            refresh_pattern .               0       20%     4320

            dns_nameservers 1.1.1.1
            ignore_unknown_nameservers off

            #dns_v4_first on

            cache_mem 1024 MB
          '';
          squid-allowed-networks = pkgs.writeText "allowed_networks.txt" ''
            127.0.0.1/24
            10.0.0.0/8
            172.16.0.0/12
            192.168.0.0/16
            100.64.0.0/10
            10.152.183.0/24
          '';
          squid-allowed-domains = pkgs.writeText "allowed_domains.txt" ''
            localhost
            .code.org
            safe.duckduckgo.com
            external-content.duckduckgo.com
            .apple.com
            .plex.tv
            .animalia.bio
            .wikipedia.org
            .linuxjourney.com
            .kids.nationalgeographic.com
            .inaturalist.org
            .coolmathgames.com
            .crunchlabs.com
            .cdn.shopify.com
            .classlink.com
            .ssanpete.org
            .adobe.com
            .mylexia.com
            .tegrity.com
            .typesy.com
            .adobe.com
            .adobeexchange.com
            .adobe.io
            .adobelogin.com
          '';
        in [
          "${squid-conf}:/etc/squid/squid.conf"
          "${squid-allowed-networks}:/etc/squid/allowed_networks.txt"
          "${squid-allowed-domains}:/etc/squid/allowed_domains.txt"
          "${squid-conf}:/etc/squid/squid.conf"
          "/opt/squid/cache:/var/spool/squid"
          "/opt/squid/log:/var/log/squid"
        ];
        extraOptions = [
          "--ulimit"
          "nofile=1024:2048"
        ];
      };
    };
  };
  services.tailscale.extraSetFlags = [
    "--accept-dns=false"
  ];

  # Use dnsmasq
  networking.networkmanager.dns = "dnsmasq";
  services.dnsmasq = {
    enable = true;
    settings = {
      no-resolv = true;
      bogus-priv = true;
      strict-order = true;
      server = [
        "2a07:a8c1::"
        "45.90.30.0"
        "2a07:a8c0::"
        "45.90.28.0"
        "/ts.net/100.100.100.100" # conditionally forward tailscale
      ];
      add-cpe-id = "9ad2ce";
    };
  };

  #environment.systemPackages = with pkgs; [
  #  rustdesk
  #];
}
