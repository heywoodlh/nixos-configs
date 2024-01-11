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
      env | grep -iq OP_SESSION || eval $(${pkgs._1password}/bin/op signin) && export OP_SESSION
      ${pkgs._1password}/bin/op "$@"
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
}
