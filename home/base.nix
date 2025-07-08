{ config, attic, pkgs, lib, home-manager, nur, myFlakes, ... }:

let
  system = pkgs.system;
  stdenv = pkgs.stdenv;
  homeDir = config.home.homeDirectory;
  atticClient = attic.packages.${system}.attic-client;
  myFish = myFlakes.packages.${system}.fish;
  myVM = myFlakes.packages.${system}.nixos-vm;
  myVim = myFlakes.packages.${system}.vim;
  myGit = myFlakes.packages.${system}.git;
  myJujutsu = myFlakes.packages.${system}.jujutsu;
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
  newsboat_browser_config = if stdenv.isDarwin then ''
    browser "open %u"
  ''
  else ''
    browser "${pkgs.xdg-utils}/bin/xdg-open %u"
  '';
  gomuks_keybindings_file = if stdenv.isDarwin
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
  op-backup-dir = if stdenv.isDarwin then
    "${homeDir}/Library/Mobile\\ Documents/com~apple~CloudDocs/password-store"
  else
    "${homeDir}/.password-store";
  op-backup-dir-no-format = if stdenv.isDarwin then
    "${homeDir}/Library/Mobile Documents/com~apple~CloudDocs/password-store"
  else
    "${homeDir}/.password-store";
  op-backup = pkgs.writeShellScriptBin "op-backup" ''
    bash ${op-backup-script} l.spencer.heywood@protonmail.com ${op-backup-dir}
  '';
  op-unlock = ''
    env | grep -iqE "^OP_SESSION" || eval $(${pkgs._1password-cli}/bin/op signin)
  '';
  op-base = ''
    ${op-unlock}
    id="$(${op-wrapper} item list | grep -vE '^ID' | ${pkgs.fzf}/bin/fzf --reverse | awk '{print $1}')"
    [[ -z "$id" ]] && exit 0 # exit if no selection was made
  '';
  op-password = pkgs.writeShellScript "op-password" ''
    ${op-base}
    ${op-wrapper} item get "$id" --fields label=password --reveal || true
  '';
  op-otp = pkgs.writeShellScript "op-otp" ''
    ${op-base}
    ${op-wrapper} item get "$id" --otp || true
  '';
  password = pkgs.writeShellScriptBin "passwords" ''
    ${op-password} | ${pkgs.tmux}/bin/tmux loadb -
  '';
  otp = pkgs.writeShellScriptBin "totp" ''
    ${op-otp} | ${pkgs.tmux}/bin/tmux loadb -
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
  tarsnap-key-backup = pkgs.writeShellScriptBin "tarsnap-key-backup.sh" ''
    hosts=("nix-drive" "nix-nvidia" "nixos-gaming")
    op_item="fp5jsqodjv3gzlwtlgojays7qe"

    for host in "''${hosts[@]}"
    do
      ssh heywoodlh@$host "sudo cp /root/tarsnap.key /home/heywoodlh/tarsnap.key; sudo chown -R heywoodlh /home/heywoodlh/tarsnap.key" && scp heywoodlh@$host:/home/heywoodlh/tarsnap.key $host && ssh heywoodlh@$host "rm /home/heywoodlh/tarsnap.key" && op-wrapper.sh item edit fp5jsqodjv3gzlwtlgojays7qe "$host[file]=$host" && rm $host
    done
  '';
  duo-key-self-setup = pkgs.writeShellScriptBin "duo-key-setup.sh" ''
    op item get 6sgj3s3755opehqifusmxxoehy --fields=unix-secret-key > /tmp/duo.key
    op item get 6sgj3s3755opehqifusmxxoehy --fields=unix-integration-key > /tmp/duo-integration.key
    chmod 600 /tmp/duo*.key
    sudo mv /tmp/duo*.key /root/
    sudo chown -R root:root /root/duo*.key
  '';
  duo-key-remote-setup = pkgs.writeShellScriptBin "duo-key-remote-setup.sh" ''
    hosts=("nix-drive" "nix-nvidia" "nixos-gaming")
    op item get 6sgj3s3755opehqifusmxxoehy --fields=unix-secret-key > /tmp/duo.key
    op item get 6sgj3s3755opehqifusmxxoehy --fields=unix-integration-key > /tmp/duo-integration.key
    chmod 600 /tmp/duo.key
    chmod 600 /tmp/duo-integration.key
    for host in "''${hosts[@]}"
    do
      scp /tmp/duo.key heywoodlh@$host:/tmp/duo.key
      scp /tmp/duo-integration.key heywoodlh@$host:/tmp/duo-integration.key
      ssh heywoodlh@$host "sudo mv /tmp/duo.key /root/duo.key; sudo chown -R root:root /root/duo.key; sudo chmod 600 /root/duo.key"
      ssh heywoodlh@$host "sudo mv /tmp/duo-integration.key /root/duo-integration.key; sudo chown -R root:root /root/duo-integration.key; sudo chmod 600 /root/duo-integration.key"
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
  altDarwin = if system == "aarch64-darwin" then "ssh://heywoodlh@intel-mac-vm x86_64-darwin" else "ssh://heywoodlh@mac-mini aarch64-darwin"; # MacOS builder on opposite arch
  altLinux = if system == "x86_64-linux" then "ssh://heywoodlh@ubuntu-arm64 aarch64-linux" else "ssh://heywoodlh@nix-nvidia x86_64-linux"; # Linux builder on opposite arch
  altBuilder = if stdenv.isDarwin then "${altLinux}" else "${altDarwin}";
  myBuilders = if stdenv.isDarwin then "ssh://heywoodlh@nix-nvidia x86_64-linux ; ssh://builder@linux-builder aarch64-linux ; ${altDarwin}" else "ssh://heywoodlh@mac-mini aarch64-darwin ; ${altLinux}";
  builder-pop = pkgs.writeShellScriptBin "builders.sh" ''
    set -ex
    # Shell script to populate SSH host keys
    ssh heywoodlh@nix-nvidia true
    ssh heywoodlh@mac-mini true
    ssh heywoodlh@ubuntu-arm64 true

    # Populate to root user
    sudo -E ssh heywoodlh@nix-nvidia true
    sudo -E ssh heywoodlh@mac-mini true
    sudo -E ssh heywoodlh@ubuntu-arm64 true
  '';
  remote-nix = pkgs.writeShellScriptBin "nix.sh" ''
    ${pkgs.nix}/bin/nix --builders "${myBuilders}" $@
  '';
  system-fetch = pkgs.writeShellScriptBin "neofetch" ''
    ${pkgs.leaf}/bin/leaf $@
  '';
  test-linux = pkgs.writeText "test-linux.sh" ''
    #!/usr/bin/env -S nix shell "github:nixos/nixpkgs/nixpkgs-unstable#bash" "github:DeterminateSystems/nix" "github:zhaofengli/attic/47752427561f1c34debb16728a210d378f0ece36#attic-client" --command bash
    cd /tmp
    set -e
    # Home-Manager
    if echo "$targets" | grep -q 'home-manager'
    then
      printf "\nTesting Home-Manager build\n"
      nix build "/tmp/nixos-configs#homeConfigurations.heywoodlh.activationPackage" --impure || echo "Failed to build home-manager"
      echo "$targets" | grep -q 'skip-cache' || nix run "github:zhaofengli/attic/47752427561f1c34debb16728a210d378f0ece36#attic-client" -- push nixos ./result
      rm -f result
    fi
    # Desktop
    if echo "$targets" | grep -q 'nixos-desktop'
    then
      printf "\nTesting NixOS Desktop build\n"
      nix run nixpkgs#nixos-rebuild -- build --flake "/tmp/nixos-configs#nixos-desktop" --impure
      echo "$targets" | grep -q 'skip-cache' || nix run "github:zhaofengli/attic/47752427561f1c34debb16728a210d378f0ece36#attic-client" -- push nixos ./result
      rm -f result
    fi
    # Server
    if echo "$targets" | grep -q 'nixos-server'
    then
      printf "\nTesting NixOS Server build\n"
      nix run nixpkgs#nixos-rebuild -- build --flake "/tmp/nixos-configs#nixos-server"
      echo "$targets" | grep -q 'skip-cache' || nix run "github:zhaofengli/attic/47752427561f1c34debb16728a210d378f0ece36#attic-client" -- push nixos ./result
      rm -f result
    fi
  '';
  test-darwin = pkgs.writeText "test-darwin.sh" ''
    #!/usr/bin/env -S nix shell "github:nixos/nixpkgs/nixpkgs-unstable#bash" "github:DeterminateSystems/nix" --command bash
    cd /tmp
    printf "\nTesting Nix-Darwin build\n"
    nix build /tmp/nixos-configs#darwinConfigurations.mac-mini.system
    nix run "github:zhaofengli/attic/47752427561f1c34debb16728a210d378f0ece36#attic-client" -- push nix-darwin ./result
    rm -f result
  '';
  nixos-configs-test = pkgs.writeShellScriptBin "nixos-configs.sh" ''
    [[ "$1" == "--help" ]] && echo "Usage: $0 [home-manager nixos-desktop nixos-server darwin] [--skip-cache]" && exit 0
    [[ -n "$1" ]] && targets="$@"
    [[ -z "$targets" ]] && targets="home-manager nixos-desktop nixos-server darwin"
    if ! echo "$targets" | ${pkgs.gnugrep}/bin/grep -qE 'home-manager|nixos-desktop|nixos-server|darwin'
    then
      echo "No valid targets specified. Please specify at least one of: home-manager, nixos-desktop, nixos-server, darwin -- or omit all arguments."
      exit 1
    fi
    # Script to test nixos-configs
    nixos_configs="$HOME/opt/nixos-configs"
    # Fallback to git repository if local repo not found
    [[ ! -d "$nixos_configs" ]] && rm -rf /tmp/nixos-configs && ${pkgs.git}/bin/git clone https://github.com/heywoodlh/nixos-configs /tmp/nixos-configs && nixos_configs="/tmp/nixos-configs"
    set -e
    # Test linux
    if echo "$targets" | ${pkgs.gnugrep}/bin/grep -qE 'home-manager|nixos-desktop|nixos-server'
    then
      for server in "dev.barn-banana.ts.net" "ubuntu-arm64.barn-banana.ts.net"
      do
        ${pkgs.openssh}/bin/ssh heywoodlh@''${server} sudo rm -rf /tmp/nixos-configs || echo "Failed to remove existing nixos-configs from ''${server}"
        echo "Copying nixos-configs to ''${server}"
        ${pkgs.openssh}/bin/scp -r ''${nixos_configs} heywoodlh@''${server}:/tmp/nixos-configs &>/dev/null || echo "Failed to copy nixos-configs to ''${server}"
        ${pkgs.openssh}/bin/ssh heywoodlh@''${server} sudo rm -f /tmp/test-linux.sh
        ${pkgs.openssh}/bin/scp ${test-linux} heywoodlh@''${server}:/tmp/test-linux.sh
        ${pkgs.openssh}/bin/ssh heywoodlh@''${server} "export targets=\"$targets\" && bash /tmp/test-linux.sh"
      done
    fi

    # Test macOS
    if echo "$targets" | ${pkgs.gnugrep}/bin/grep -qE 'darwin'
    then
      ${pkgs.openssh}/bin/ssh heywoodlh@mac-mini.barn-banana.ts.net sudo rm -rf /tmp/nixos-configs || echo "Failed to remove existing nixos-configs from mac-mini"
      ${pkgs.openssh}/bin/scp -r ''${nixos_configs} heywoodlh@mac-mini.barn-banana.ts.net:/tmp/nixos-configs &>/dev/null || echo "Failed to copy nixos-configs to mac-mini"
      ${pkgs.openssh}/bin/ssh heywoodlh@mac-mini.barn-banana.ts.net sudo rm -f /tmp/test-darwin.sh
      ${pkgs.openssh}/bin/scp ${test-darwin} heywoodlh@mac-mini.barn-banana.ts.net:/tmp/test-darwin.sh
      ${pkgs.openssh}/bin/ssh heywoodlh@mac-mini.barn-banana.ts.net "export targets=\"$targets\" && zsh /tmp/test-darwin.sh"
    fi
  '';
  youtube-dl-mp3 = pkgs.writeShellScriptBin "youtube-dl-mp3" ''
    ${pkgs.nix}/bin/nix run "github:nixos/nixpkgs/nixpkgs-unstable#yt-dlp" -- -t mp3 "$@"
  '';
in {
  home.stateVersion = "24.11";
  home.enableNixpkgsReleaseCheck = false;

  nix = {
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
    go
    htop
    inetutils
    jq
    k9s
    kubectl
    kubernetes-helm
    lefthook
    less
    libarchive
    lima
    nixos-rebuild-ng
    nixfmt-rfc-style
    nmap
    openssl
    ollama
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
    myJujutsu
    myFlakes.packages.${system}.tmux
    myFish # For non-nix use-cases
    #myVM
    todomanWrapper
    vimTodoAdd
    password
    otp
    op-backup
    duo-key-self-setup
    duo-key-remote-setup
    builder-pop
    remote-nix
    system-fetch
    atticClient
    nixos-configs-test
    youtube-dl-mp3
  ];

  # Enable password-store
  programs.password-store = {
    enable = true;
    package = myPass;
  };

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

  home.file.".config/fish/machine.fish" = {
    text = ''
      function ssh-unlock
        set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
        if ! ${pkgs.ps}/bin/ps -fjH -u $USER | ${pkgs.gnugrep}/bin/grep ssh-agent | ${pkgs.gnugrep}/bin/grep -q "$HOME/.ssh/agent.sock" &> /dev/null
            mkdir -p $HOME/.ssh
            rm -f $HOME/.ssh/agent.sock &> /dev/null
            eval $(${pkgs.openssh}/bin/ssh-agent -t 4h -c -a "$HOME/.ssh/agent.sock") &> /dev/null || true
        else
            # Start ssh-agent if old process exists but socket file is gone
            # Or if SSH_AUTH_SOCK != $HOME/.ssh/agent.sock
            if ! test -e $HOME/.ssh/agent.sock || test "$SSH_AUTH_SOCK" != "$HOME/.ssh/agent.sock"
              # Kill old ssh-agent process
              ${pkgs.procps}/bin/pkill -9 ssh-agent &> /dev/null || true
              eval $(${pkgs.openssh}/bin/ssh-agent -t 4h -c -a "$HOME/.ssh/agent.sock") &> /dev/null || true
            end
        end
        ${op-wrapper} read 'op://Personal/rlt3q545cf5a4r4arhnb4h5qmi/private_key' | ${pkgs.openssh}/bin/ssh-add -t 4h -
      end
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
      outgoing-cred-cmd = ${op-wrapper} read 'op://Personal/7xgfk5ve2zeltpeyglwephqtsq/bridge'
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
    text = let
      atuinConfig = pkgs.writeText "" ''
        auto_sync = true
        update_check = true
        sync_address = "http://atuin:8888"
        enter_accept = false
      '';
      atuinConfigDir = pkgs.stdenv.mkDerivation {
        name = "atuinConfigDir";
        builder = pkgs.bash;
        args = [ "-c" "${pkgs.coreutils}/bin/mkdir -p $out/atuin; ${pkgs.coreutils}/bin/cp ${atuinConfig} $out/atuin/config.toml;" ];
      };
    in ''
      set -g PATH "${pkgs.atuin}/bin" $PATH
      set -gx ATUIN_CONFIG_DIR "${atuinConfigDir}/atuin"
      ${pkgs.atuin}/bin/atuin init fish --disable-up-arrow | source

      # Remove all 1Password session variables
      function op-clear
        set --erase (set | ${pkgs.gnugrep}/bin/grep "OP_SESSION_" | ${pkgs.coreutils}/bin/cut -d' ' -f1) &>/dev/null || true
      end

      function vultr-unlock
        export VULTR_API_KEY="$(${op-wrapper} read 'op://Personal/dr4b7omthk7nmwkzbe3nwkrhka/api_key')"
      end

      function github-unlock
        set -gx NIX_CONFIG "access-tokens = github.com=$(${op-wrapper} item get github.com/heywoodlh/personal-access-token --fields=password --reveal)"
      end

      export OLLAMA_HOST="nix-nvidia.barn-banana.ts.net:11434"

      function lnav
        kubectl exec -it -n monitoring $(kubectl get pods -n monitoring | grep -i lnav | head -1 | awk '{print $1}') -- env TERM="screen-256color" lnav /logs $argv
      end

      # Config file that gets loaded very last
      test -e ~/.config/fish/override.fish && source ~/.config/fish/override.fish || true
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
      ${op-unlock}
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

  # Jujutsu config
  # Configs not specified here are in my jujutsu flake
  home.file.".config/jujutsu/config.toml".text = let
    osConf = if stdenv.isDarwin then ''
      # optional, but recommended
      # not setting on Linux because it's not needed
      [signing.backends.ssh]
      program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    '' else "";
  in ''
    [signing]
    sign-all = true
    backend = "ssh"
    key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ=="

    ${osConf}
  '';

  home.file.".ssh/config".text = let
    # Lazy: assume I'm either on Apple Silicon MacOS or Intel Linux
    altBuilder = if stdenv.isLinux then "ubuntu-arm64" else "intel-mac-vm";
    authSock = if stdenv.isLinux then "${homeDir}/.ssh/agent.sock" else "${homeDir}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"; # always assume 1password on MacOS
    builders = if stdenv.isLinux then "mac-mini intel-mac-vm ${altBuilder}" else "nix-nvidia ubuntu-arm64 ${altBuilder}";
  in ''
    # User-wide SSH config for nix builders
      Host ${builders}
        IdentityAgent "${authSock}"
  '';
  nix.settings.builders = myBuilders;

  home.file.".config/vim/vimrc" = {
    text = let
      ollama = "http://nix-nvidia.barn-banana.ts.net:11434";
    in ''
      lua << EOF
        local llm = require('llm')
        llm.setup({
          lsp = {
            bin_path = "${pkgs.llm-ls}/bin/llm-ls",
          },
          model = "deepseek-coder:6.7b",
          backend = "ollama",
          url = "${ollama}",
          request_body = {
            temperature = 0.2,
            top_p = 0.95,
            system = "Complete the given code without explanation. Respond only with the code. Do not place the code in markdown. Do not place the code in markdown. Fill in the middle requests will be used.",
          },
          fim = {
            enabled = true,
          },
          debounce_ms = 150,
          enable_suggestions_on_startup = false,
          enable_suggestions_on_files = '*.sh,*.fish,*.zsh,*.go,*.nix,*.py,*.lua,*.java,*.js,*.jsx,*.ts,*.tsx,*.html,*.css,*.scss,*.json,*.yaml,*.yml,*.toml',
          context_window = 10240,
          accept_keymap = "<Tab>",
          dismiss_keymap = "<S-Tab>",
        })

        require("codecompanion").setup({
          strategies = {
            chat = {
              adapter = "ollama",
            },
            inline = {
              adapter = "ollama",
            },
          },
          adapters = {
            ollama = function()
              return require("codecompanion.adapters").extend("ollama", {
                env = {
                  url = "${ollama}",
                },
                headers = {
                  ["Content-Type"] = "application/json",
                },
                parameters = {
                  sync = true,
                },
                schema = {
                  model = {
                    default = "llama3:8b",
                  },
               },
              })
            end,
            openai = function()
              return require("codecompanion.adapters").extend("openai", {
                env = {
                  api_key = "cmd:${op-wrapper} read 'op://Personal/wnnzk4qgffnymdqdhbmzgruquq/api-key' --no-newline",
                },
              })
            end,
          },
        })
      EOF
    '';
  };
  heywoodlh.home.docker-credential-1password.enable = true;
  #home.file.".docker/config.json".text = if pkgs.stdenv.isDarwin then ''
  #  {
  #      "auths": {
  #          "docker.io": {},
  #          "ghcr.io": {}
  #      },
  #      "credsStore": "1password",
  #      "credHelpers": {
  #          "docker.io": "1password",
  #          "ghcr.io": "1password"
  #      },
  #      "currentContext": "docker-lima"
  #  }
  #'' else ''
  #  {
  #      "auths": {
  #          "docker.io": {},
  #          "ghcr.io": {}
  #      },
  #      "credsStore": "1password",
  #      "credHelpers": {
  #          "docker.io": "1password",
  #          "ghcr.io": "1password"
  #      },
  #      "currentContext": "rootless"
  #  }
  #'';
}
