{ config, pkgs, home-manager, nur, myFlakes, ... }:

let
  system = pkgs.system;
  homeDir = config.home.homeDirectory;
  myTmux = myFlakes.packages.${system}.tmux;
  myFish = myFlakes.packages.${system}.fish;
  myVM = myFlakes.packages.${system}.nixos-vm;
  myVim = myFlakes.packages.${system}.vim;
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
    env | grep -iqE "^OP_SESSION" || eval $(${pkgs._1password}/bin/op signin) && export OP_SESSION
    ${pkgs._1password}/bin/op --account my "$@"
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
    ${op-password} | ${pkgs.tmux}/bin/tmux loadb -
  '';
  otp = pkgs.writeShellScriptBin "otp" ''
    ${op-otp} | ${pkgs.tmux}/bin/tmux loadb -
  '';
  passOtp = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
  myPass = pkgs.writeShellScriptBin "pass" ''
    PASSWORD_STORE_DIR="${op-backup-dir-no-format}" ${passOtp}/bin/pass $@
  '';
in {
  home.stateVersion = "23.11";
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
    vdirsyncer
    zip
    myVim
    myGit
    myTmux # For non-nix use-cases
    myFish # For non-nix use-cases
    #myVM
    todomanWrapper
    vimTodoAdd
    password
    otp
    op-backup
    myPass
  ];

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

  # 1Password CLI wrapper
  home.file."bin/op-wrapper.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      env | grep -iqE "^OP_SESSION" || eval $(${pkgs._1password}/bin/op signin) && export OP_SESSION
      ${pkgs._1password}/bin/op --account my "$@"
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
      ${homeDir}/bin/op-wrapper.sh read 'op://Personal/rlt3q545cf5a4r4arhnb4h5qmi/private_key' | ${pkgs.openssh}/bin/ssh-add -t 4h -
    '';
  };

  # Aerc
  home.file.".config/aerc/accounts.conf" = {
    enable = true;
    text = ''
      [fastmail]
      source = imaps://heywoodlh%40heywoodlh.io@imap.fastmail.com:993
      source-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/3qaxsqbv5dski4wqswxapc7qoi/password'
      outgoing = smtps://heywoodlh%40heywoodlh.io@smtp.fastmail.com:465
      outgoing-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/3qaxsqbv5dski4wqswxapc7qoi/password'
      default = INBOX
      copy-to = Sent
      from = Spencer Heywood <heywoodlh@heywoodlh.io>

      [protonmail]
      source = imap+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:143
      source-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/6fqlleymphwgzsvqp7jfsucz4m/password'
      outgoing = smtp+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:25
      outgoing-cred-cmd = ${homeDir}/bin/op-wrapper.sh read 'op://Personal/6fqlleymphwgzsvqp7jfsucz4m/password'
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
      miniflux-passwordeval "${homeDir}/bin/op-wrapper.sh read 'op://Kubernetes/3jdvjlmc67dfngycergck6ikxq/password'"

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
        export VULTR_API_KEY="$(op read 'op://Personal/biw7pdtbal7zj66gu6ylaavgui/api_key')"
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
      password.fetch = ["shell", "${homeDir}/bin/op-wrapper.sh item get '3qaxsqbv5dski4wqswxapc7qoi' --fields label=password"]
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

}
