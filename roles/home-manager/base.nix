{ config, pkgs, home-manager, nur, myFlakes, ... }:

let
  homeDir = config.home.homeDirectory;
  aerc-html-filter = pkgs.writeScriptBin "html" ''
    export SOCKS_SERVER="127.0.0.1:1"
    exec ${pkgs.dante}/bin/socksify ${pkgs.w3m}/bin/w3m \
      -T text/html \
      -cols $(${pkgs.ncurses}/bin/tput cols) \
      -dump \
      -o display_image=false \
      -o display_link_number=true
  '';
  system = pkgs.system;
  myTmux = myFlakes.packages.${system}.tmux;
  myFish = myFlakes.packages.${system}.fish;
  myVM = myFlakes.packages.${system}.ubuntu-vm;
  newsboat_browser = if pkgs.stdenv.isDarwin then ''
    browser "open %u"
  ''
  else ''
    browser "${pkgs.xdg-utils}/bin/xdg-open %u"
  '';
  gomuks_keybindings_file = if pkgs.stdenv.isDarwin
  then "Library/Application Support/gomuks/keybindings.yaml"
  else ".config/gomuks/keybindings.yaml";
in {
  home.stateVersion = "23.05";
  home.enableNixpkgsReleaseCheck = false;
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Packages I need installed on every system
  home.packages = with pkgs; [
    _1password
    bind
    coreutils
    curl
    dos2unix
    file
    findutils
    fzf
    gcc
    github-cli
    gitleaks
    gnupg
    gnumake
    gnused
    gomuks
    htop
    inetutils
    jq
    lefthook
    libarchive
    libvirt
    lima
    mosh
    nixos-rebuild
    nmap
    openssl
    pciutils
    pwgen
    python3
    screen
    tcpdump
    tree
    unzip
    zip
    myTmux # For non-nix use-cases
    myFish # For non-nix use-cases
    myVM
  ];

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [
    nur.overlay
  ];

  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  };

  home.file."tmp/.placeholder.txt" = {
    text = "";
  };

  home.file."share/redirector.json" = {
    text = import ./share/redirector.json.nix;
  };

  # 1Password CLI wrapper
  home.file."bin/op-wrapper.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      env | grep -iqE "^OP_SESSION" || eval $(${pkgs._1password}/bin/op signin) && export OP_SESSION
      ${pkgs._1password}/bin/op --account my "$@"
    '';
  };

  # Proxychains wrapper
  home.file."bin/proxychains" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      ${pkgs.proxychains-ng}/bin/proxychains4 "$@"
    '';
  };

  # Proxychains configs
  home.file.".proxychains/proxychains.conf" = {
    enable = true;
    text = ''
      strict_chain
      proxy_dns
      quiet_mode
      remote_dns_subnet 224
      tcp_read_time_out 15000
      tcp_connect_time_out 8000
      localnet 127.0.0.0/255.0.0.0
      [ProxyList]
      socks5 100.113.9.57 1080
    '';
  };

  home.file."bin/op" = {
    enable = true;
    executable = true;
    text = ''
      ${homeDir}/bin/op-wrapper.sh $@
    '';
  };

  home.file."bin/ssh-unlock" = {
    enable = true;
    executable = true;
    text = ''
      ${homeDir}/bin/op-wrapper.sh read 'op://Personal/uwxs2btf3eoweg4phzag2hfkge/private_key' | ${pkgs.openssh}/bin/ssh-add -t 4h -
    '';
  };

  # Aerc
  home.file.".config/aerc/accounts.conf" = {
    enable = true;
    text = ''
      [fastmail]
      source = imaps://heywoodlh%40heywoodlh.io@imap.fastmail.com:993
      source-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/44abj6tnhmrjdhv6potivbc5by/password'
      outgoing = smtps://heywoodlh%40heywoodlh.io@smtp.fastmail.com:465
      outgoing-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/44abj6tnhmrjdhv6potivbc5by/password'
      default = INBOX
      copy-to = Sent
      from = Spencer Heywood <heywoodlh@heywoodlh.io>

      [protonmail]
      source = imap+insecure://l.spencer.heywood%40protonmail.com@nix-ext-net.tailscale:143
      source-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/erkt5oy644dks54kax57ib2rue/password'
      outgoing = smtp+plain://l.spencer.heywood%40protonmail.com@nix-ext-net.tailscale:25
      outgoing-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/erkt5oy644dks54kax57ib2rue/password'
      default = INBOX
      copy-to = Sent
      from = Spencer Heywood <l.spencer.heywood@protonmail.com>
    '';
  };
  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      filters = {
        "text/html" = "${aerc-html-filter}/bin/html";
        "text/plain" = "${pkgs.coreutils}/bin/fold -w 80";
      };
    };
  };

  programs.newsboat = {
    enable = true;
    extraConfig = ''
      urls-source "miniflux"
      miniflux-url "https://feeds.heywoodlh.io"
      miniflux-login "heywoodlh"
      miniflux-passwordeval "${homeDir}/bin/op-wrapper.sh read 'op://Personal/a4johfsgd7cnpzulsqcgkavhoq/password'"

      # general settings
      auto-reload yes
      max-items 50
      ${newsboat_browser}

      # unbind keys
      unbind-key j
      unbind-key k
      unbind-key J
      unbind-key K

      # vim keybindings
      bind-key j down
      bind-key k up
      bind-key l open
      bind-key h quit

      # solarized
      color background         default   default
      color listnormal         default   default
      color listnormal_unread  default   default
      color listfocus          black     cyan
      color listfocus_unread   black     cyan
      color info               default   black
      color article            default   default

      # highlights
      highlight article "^(Title):.*$" blue default
      highlight article "https?://[^ ]+" red default
      highlight article "\\[image\\ [0-9]+\\]" green default
    '';
  };

  home.file."${gomuks_keybindings_file}" = {
    text = ''
      main:
        'Ctrl+Down': next_room
        'Ctrl+Up': prev_room
        'Ctrl+k': search_rooms
        'Ctrl+Home': scroll_up
        'Ctrl+End': scroll_down
        'Ctrl+Enter': add_newline
        'Ctrl+l': show_bare
        'Ctrl+n': next_room
        'Ctrl+p': prev_room
        'Alt+k':  search_rooms
        'Alt+Home': scroll_up
        'Alt+End': scroll_down
        'Alt+Enter': add_newline
        'Alt+a': next_active_room
        'Alt+l': show_bare

      modal:
        'Tab': select_next
        'Down': select_next
        'Backtab': select_prev
        'Up': select_prev
        'Enter': confirm
        'Escape': cancel

      visual:
        'Escape': clear
        'h': clear
        'Up': select_prev
        'k': select_prev
        'Down': select_next
        'j': select_next
        'Enter': confirm
        'l': confirm

      room:
        'Escape': clear
        'Ctrl+p': scroll_up
        'Ctrl+n': scroll_down
        'PageUp': scroll_up
        'PageDown': scroll_down
        'Enter': send
    '';
  };

  # config.fish
  home.file.".config/fish/config.fish" = {
    enable = true;
    text = ''
      function vultr-unlock
        export VULTR_API_KEY="$(op read 'op://Personal/biw7pdtbal7zj66gu6ylaavgui/api_key')"
      end
    '';
  };
}
