{ config, pkgs, lib, home-manager, nur, myFlakes, ts-warp-nixpkgs, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myZellij = myFlakes.packages.${system}.zellij;
  myFish = myFlakes.packages.${system}.fish;
  myVM = myFlakes.packages.${system}.nixos-vm;
  myVim = myFlakes.packages.${system}.vim;
  myHelix = myFlakes.packages.${system}.helix;
  myGit = myFlakes.packages.${system}.git;
  aerc-html-filter = pkgs.writeScriptBin "html" ''
    export SOCKS_SERVER="nix-nvidia:1080"
    exec ${pkgs.dante}/bin/socksify ${pkgs.w3m}/bin/w3m \
      -T text/html \
      -cols $(${pkgs.ncurses}/bin/tput cols) \
      -dump \
      -o display_image=false \
      -o display_link_number=true
  '';
  todomanWrapper = pkgs.writeScriptBin "todo" ''
    ${pkgs.vdirsyncer}/bin/vdirsyncer sync &>/dev/null && ${pkgs.todoman}/bin/todo "$@" && ${pkgs.vdirsyncer}/bin/vdirsyncer sync &>/dev/null
  '';
  vimTodoAdd = pkgs.writeScriptBin "todo-vim" ''
    output="$(${pkgs.coreutils}/bin/printf "Summary: \n\n#Example Date:$(${pkgs.coreutils}/bin/date "+%Y-%m-%d %H:%M")\nDue: " | EDITOR='${myVim}/bin/vim' ${pkgs.moreutils}/bin/vipe)"
    summary="$(${pkgs.coreutils}/bin/printf "$output" | ${pkgs.gnugrep}/bin/grep 'Summary:' | ${pkgs.coreutils}/bin/cut -d ':' -f 2 | ${pkgs.findutils}/bin/xargs | ${pkgs.gnused}/bin/sed 's/  / /g')"
    date="$(${pkgs.coreutils}/bin/printf "$output" | ${pkgs.gnugrep}/bin/grep 'Due:' | ${pkgs.coreutils}/bin/cut -d ':' -f 2 | ${pkgs.findutils}/bin/xargs)"
    if [ -n "$summary" ]
    then
      if [[ -n $date ]]
      then
        datearg="--due $date"
        ${todomanWrapper}/bin/todo new "$datearg" "$summary"
      else
        ${todomanWrapper}/bin/todo new "$summary"
      fi
    fi
  '';
  newsboat_browser_config = if pkgs.stdenv.isDarwin then ''
    browser "open %u"
  ''
  else ''
    browser "${pkgs.xdg-utils}/bin/xdg-open %u"
  '';
  gomuks_keybindings_file = if pkgs.stdenv.isDarwin
  then "Library/Application Support/gomuks/keybindings.yaml"
  else ".config/gomuks/keybindings.yaml";
  op-wrapper = pkgs.writeShellScript "op-wrapper.sh" ''
    env | grep -iqE "^OP_SESSION" || eval $(${pkgs._1password-cli}/bin/op signin) && export OP_SESSION
    ${pkgs._1password-cli}/bin/op --account my "$@"
  '';
  op-backup-script = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/heywoodlh/1password-pass-backup/c938124eff5dddd3aad226a5a5a6ae65441211b7/backup.sh";
    sha256 = "sha256:12cbni566245m513r2w8lng11gzbl148mlnlscwzwbkxhpacwz9d";
  };
  op-backup-dir = if pkgs.stdenv.isDarwin then
    "${homeDir}/Library/Mobile\\ Documents/com~apple~CloudDocs/password-store"
  else
    "${homeDir}/.password-store";
  op-backup-dir-no-format = if pkgs.stdenv.isDarwin then
    "${homeDir}/Library/Mobile Documents/com~apple~CloudDocs/password-store"
  else
    "${homeDir}/.password-store";
  op-backup = pkgs.writeShellScriptBin "op-backup" ''
    bash ${op-backup-script} l.spencer.heywood@protonmail.com ${op-backup-dir}
  '';
  op-base = ''
    id="$(${op-wrapper} item list | grep -vE '^ID' | ${pkgs.fzf}/bin/fzf --reverse | awk '{print $1}')"
    [[ -z "$id" ]] && exit 0 # exit if no selection was made
  '';
  op-password = pkgs.writeShellScript "op-password" ''
    ${op-base}
    ${op-wrapper} item get "$id" --fields label=password || true
  '';
  op-otp = pkgs.writeShellScript "op-otp" ''
    ${op-base}
    ${op-wrapper} item get "$id" --otp || true
  '';
  password = pkgs.writeShellScriptBin "password" ''
    ${op-password}
  '';
  otp = pkgs.writeShellScriptBin "otp" ''
    ${op-otp}
  '';
  myPass = pkgs.writeShellScriptBin "pass" ''
    export PASSWORD_STORE_DIR="${op-backup-dir-no-format}"
    ${pkgs.pass.withExtensions (exts: [ exts.pass-otp ])}/bin/pass $@
  '';
  limaTemplate = ./share/ubuntu.yaml;
  tor-proxychains-conf = pkgs.writeText "proxychains.conf" ''
    strict_chain
    proxy_dns
    quiet_mode
    remote_dns_subnet 224
    tcp_read_time_out 15000
    tcp_connect_time_out 8000
    localnet 127.0.0.0/255.0.0.0
    [ProxyList]
    socks5 tor.barn-banana.ts.net 1080
  '';
  ts-warp = ts-warp-nixpkgs.legacyPackages.${system}.ts-warp;
  ts-warp-pf = ./share/ts-warp_pf.conf;
  ts-warp-ini = ./share/ts-warp.ini;
  incognito = if pkgs.stdenv.isDarwin then pkgs.writeShellScriptBin "incognito" ''
    test -d /usr/local/etc || sudo mkdir -p /usr/local/etc
    test -f /usr/local/etc/ts-warp_pf.conf || sudo cp ${ts-warp-pf} /usr/local/etc/ts-warp_pf.conf
    test -f /usr/local/etc/ts-warp.ini || sudo cp ${ts-warp-ini} /usr/local/etc/ts-warp.ini
    sudo ${ts-warp}/etc/ts-warp.sh start
  '' else pkgs.writeShellScriptBin "incognito" ''
    ${pkgs.proxychains-ng}/bin/proxychains4 -f ${tor-proxychains-conf} ${myFish}/bin/fish --private
  '';
  tarsnap-key-backup = pkgs.writeShellScriptBin "tarsnap-key-backup.sh" ''
    hosts=("nix-drive" "nix-nvidia" "nixos-gaming" "nixos-mac-mini")
    op_item="fp5jsqodjv3gzlwtlgojays7qe"

    for host in "''${hosts[@]}"
    do
      ssh heywoodlh@$host "sudo cp /root/tarsnap.key /home/heywoodlh/tarsnap.key; sudo chown -R heywoodlh /home/heywoodlh/tarsnap.key" && scp heywoodlh@$host:/home/heywoodlh/tarsnap.key $host && ssh heywoodlh@$host "rm /home/heywoodlh/tarsnap.key" && op-wrapper.sh item edit fp5jsqodjv3gzlwtlgojays7qe "$host[file]=$host" && rm $host
    done
  '';
  duo-key-setup = pkgs.writeShellScriptBin "duo-key-setup.sh" ''
    hosts=("nix-drive" "nix-nvidia" "nixos-gaming" "nixos-mac-mini")
    op item get 6sgj3s3755opehqifusmxxoehy --fields=unix-secret-key > /tmp/duo.key
    chmod 600 /tmp/duo.key
    for host in "''${hosts[@]}"
    do
      scp /tmp/duo.key heywoodlh@$host:/tmp/duo.key
      scp /tmp/duo-integration.key heywoodlh@$host:/tmp/duo-integration.key
      ssh heywoodlh@$host "sudo mv /tmp/duo.key /root/duo.key; sudo chown -R root:root /root/duo.key; sudo chmod 600 /root/duo.key"
    done
    rm /tmp/duo.key
  '';
  docker-compose-txt = pkgs.writeText "docker-compose.yml" ''
    services:
      ubuntu:
        image: docker.io/ubuntu
        #build: .
        restart: unless-stopped
        #network_mode: host
        ports:
          - "5000:5000"
        volumes:
          - ./code:/code
        environment:
          - SOMEVAR="true"
        #depends_on:
          #redis:
        #networks:
          #- mynet
      #redis:
        #image: docker.io/redis
        #restart: unless-stopped
        #networks:
          #- mynet

    #networks:
      #mynet:
  '';
  docker-compose-gen = pkgs.writeShellScriptBin "docker-compose-gen.sh" ''
    [[ -z $1 ]] && printf "Please provide filename.\nUsage: $0 docker-compose.yml\nExiting.\n" && exit 0
    set -ex
    cp ${docker-compose-txt} "$1"
    [[ -f "$1" ]] && chmod +w "$1"
  '';
in {
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;
  nix = {
    package = lib.mkForce pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports = [
    ./modules/default.nix
  ];

  # Packages I need installed on every system
  home.packages = with pkgs; [
    _1password-cli
    act
    bind
    coreutils
    curl
    docker-compose-gen
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
    #helix-gpt
    htop
    inetutils
    jq
    k9s
    kubectl
    kubernetes-helm
    lefthook
    libarchive
    lima
    myHelix
    nixos-rebuild
    nixfmt-rfc-style
    nmap
    openssl
    pciutils
    pwgen
    python3
    screen
    tarsnap-key-backup
    tcpdump
    tree
    unzip
    vdirsyncer
    zip
    myVim
    myGit
    myZellij # For non-nix use-cases
    myFish # For non-nix use-cases
    #myVM
    todomanWrapper
    vimTodoAdd
    password
    otp
    op-backup
    incognito
    duo-key-setup
  ];

  # Enable password-store
  programs.password-store = {
    enable = true;
    package = myPass;
  };

  # Import nur as nixpkgs.overlays
  nixpkgs.overlays = [
    nur.overlay
  ];

  home.file."tmp/.placeholder.txt" = {
    text = "";
  };

  home.file."share/redirector.json" = {
    text = import ./share/redirector.json.nix;
  };
  home.file."share/vimium-options.json" = {
    text = import ./share/vimium-options.json.nix;
  };

  # 1Password CLI wrapper
  home.file."bin/op-wrapper.sh" = {
    executable = true;
    source = op-wrapper;
  };

  home.file."bin/op" = {
    enable = true;
    executable = true;
    source = op-wrapper;
  };

  home.file."bin/ssh-unlock" = {
    enable = true;
    executable = true;
    text = ''
      ${op-wrapper} read 'op://Personal/rlt3q545cf5a4r4arhnb4h5qmi/private_key' | ${pkgs.openssh}/bin/ssh-add -t 4h -
    '';
  };

  # Aerc
  home.file.".config/aerc/accounts.conf" = {
    enable = true;
    text = ''
      [fastmail]
      source = imaps://heywoodlh%40heywoodlh.io@imap.fastmail.com:993
      source-cred-cmd = ${op-wrapper} read 'op://Personal/3qaxsqbv5dski4wqswxapc7qoi/password'
      outgoing = smtps://heywoodlh%40heywoodlh.io@smtp.fastmail.com:465
      outgoing-cred-cmd = ${op-wrapper} read 'op://Personal/3qaxsqbv5dski4wqswxapc7qoi/password'
      default = INBOX
      copy-to = Sent
      from = Spencer Heywood <heywoodlh@heywoodlh.io>
      aliases = *@heywoodlh.io

      [protonmail]
      source = imap+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:143
      source-cred-cmd = ${op-wrapper} read 'op://Personal/7xgfk5ve2zeltpeyglwephqtsq/bridge'
      outgoing = smtp+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:25
      outgoing-cred-cmd = ${op-wrapper} read 'op://Personal/6fqlleymphwgzsvqp7jfsucz4m/password'
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
      miniflux-url "http://miniflux"
      miniflux-login "heywoodlh"
      miniflux-passwordeval "${op-wrapper} read 'op://Kubernetes/3jdvjlmc67dfngycergck6ikxq/password'"

      # general settings
      auto-reload yes
      max-items 50
      ${newsboat_browser_config}

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
        export VULTR_API_KEY="$(${op-wrapper} read 'op://Personal/biw7pdtbal7zj66gu6ylaavgui/api_key')"
      end

      function github-unlock
        set -gx NIX_CONFIG "access-tokens = github.com=$(${op-wrapper} item get github.com/heywoodlh/personal-access-token --fields=password)"
      end
    '';
  };

  # vdirsyncer
  home.file.".config/vdirsyncer/config" = {
    enable = true;
    text = ''
      [general]
      status_path = "${homeDir}/.config/vdirsyncer/status/"

      [pair my_todo]
      a = "fastmail_local"
      b = "fastmail_remote"
      collections = ["from a", "from b"]

      [storage fastmail_local]
      type = "filesystem"
      path = "~/.todo/fastmail"
      fileext = ".ics"

      [storage fastmail_remote]
      type = "caldav"
      item_types = ["VTODO"]
      url = "https://caldav.fastmail.com"
      username = "heywoodlh@heywoodlh.io"
      password.fetch = ["shell", "${op-wrapper} item get '3qaxsqbv5dski4wqswxapc7qoi' --fields label=password"]
    '';
  };

  # todoman
  home.file.".config/todoman/config.py" = {
    enable = true;
    text = ''
      path = "~/.todo/fastmail/*"
      date_format = "%Y-%m-%d"
      time_format = "%H:%M"
      default_list = "FF7A0137-4E3F-4C31-A6C7-C49FE1C91631" # Professional
      default_due = 0
      default_command = "list --sort created_at --no-reverse"
    '';
  };

  # aerc wrapper
  home.file."bin/aerc" = {
    executable = true;
    text = ''
      #!/usr/bin/env fish
      op-unlock
      ${pkgs.aerc}/bin/aerc "$argv"
    '';
  };

  # lima wrapper
  home.file."bin/linux.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      if [[ -e ~/.lima/default ]]
      then
        ${pkgs.lima}/bin/limactl start default
      else
        ${pkgs.lima}/bin/limactl start --name=default ${limaTemplate}
      fi
      ${pkgs.lima}/bin/limactl start-at-login default
    '';
  };

  # nostui wrapper
  home.file."bin/nostui" = let
    configDir = if pkgs.stdenv.isDarwin then
    "${homeDir}/Library/Application Support/io.0m1.nostui"
    else "${homeDir}/.config/nostui";
  in {
    executable = true;
    text = ''
      #!/usr/bin/env fish
      if ! test -e "${configDir}"/config.json
        mkdir -p "${configDir}"
        op-unlock
        ${op-wrapper} item get ttqmeotpae3h77q7mh7dqdxy4u --fields config | sed 's/""/"/g' | sed 's/^"{/{/g' | sed 's/}"$/}/g' > "${configDir}"/config.json
      end
      nix run "github:heywoodlh/nixpkgs/nostui-init#nostui" -- $argv
    '';
  };

  # Helix configuration
  #programs.helix = {
  #  enable = true;
  #  package = myHelix;
  #  languages = {
  #    language-server.gpt = {
  #      command = "helix-gpt";
  #      environment = {
  #        HANDLER = "codeium";
  #      };
  #    };
  #    language = [
  #      {
  #        name = "bash";
  #        language-servers = [ "bash-language-server" "gpt" ];
  #      }
  #      {
  #        name = "nix";
  #        language-servers = [ "nil" "nixd" "gpt" ];
  #      }
  #      {
  #        name = "python";
  #        language-servers = [ "ruff" "jedi" "pylsp" "gpt" ];
  #      }
  #      {
  #        name = "fish";
  #        language-servers = [ "gpt" ];
  #      }
  #      {
  #        name = "swift";
  #        language-servers = [ "sourcekit-lsp" "gpt" ];
  #      }
  #    ];
  #  };
  #};
}
