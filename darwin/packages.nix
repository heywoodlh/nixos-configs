{ config, pkgs, ... }:

let
  user_name = "heywoodlh";
  user_full_name = "Spencer Heywood";
  user_description = "Spencer Heywood";
  user_packages = [
    pkgs.gcc
    pkgs.git
    pkgs.gnupg
    pkgs.skhd
    pkgs.wireguard-tools
    pkgs.yabai
  ];
  user_brew_formulae = [
    "ansible"
    "aerc"
    "argocd"
    "aria2"
    "aws-iam-authenticator"
    "awscli"
    "bandit"
    "bash"
    "buildkit"
    "browserpass"
    "choose-gui"
    "cliclick"
    "coreutils"
    "curl"
    "dante"
    "dos2unix"
    "ffmpeg"
    "findutils"
    "fzf"
    "gcc"
    "glib"
    "gnupg"
    "gnu-sed"
    "gh"
    "git"
    "go"
    "harfbuzz"
    "hashcat"
    "helm"
    "htop"
    "jailkit"
    "jq"
    "jwt-cli"
    "k9s"
    "kompose"
    "kubectl"
    "lefthook"
    "libolm"
    "lima"
    "m-cli"
    "mas"
    "mosh"
    "neofetch"
    "node"
    "openssl@3"
    "pandoc"
    "pass"
    "pass-otp"
    "pinentry-mac"
    "popeye"
    "pre-commit"
    "proxychains-ng"
    "pwgen"
    "python"
    "ripgrep"
    "screen"
    "speedtest-cli"
    "tarsnap"
    "tcpdump"
    "tfenv"
    "tmux"
    "tor"
    "torsocks"
    "tree"
    "vim"
    "vultr-cli"
    "watch"
    "w3m"
    "weechat"
    "wireguard-go"
    "wireguard-tools"
    "zsh"
  ];
  user_brew_taps = [
    "homebrew/cask"
    "homebrew/cask-drivers"
    "homebrew/cask-fonts"
    "homebrew/cask-versions"
    "homebrew/core"
    "homebrew/services"
    "vultr/vultr-cli"
    "amar1729/formulae"
    "derailed/k9s"
    "derailed/popeye"
    "colindean/fonts-nonfree"
    "kidonng/malt"
    "mike-engel/jwt-cli"
  ];
  user_brew_casks = [
    "android-platform-tools"
    "atomic-wallet"
    "beeper"
    "bitwarden"
    "blockblock"
    "brave-browser"
    "burp-suite"
    "caffeine"
    "cursorcerer"
    "discord"
    "element"
    "docker"
    "firefox"
    "font-iosevka"
    "font-microsoft-office"
    "hiddenbar"
    "iterm2"
    "knockknock"
    "lastpass"
    "lulu"
    "microsoft-remote-desktop"
    "microsoft-teams"
    "moonlight"
    "obs"
    "obsidian"
    "oversight"
    "plex"
    "plex-media-player"
    "ransomwhere"
    "raycast"
    "reikey"
    "screens"
    "secretive"
    "signal"
    "slack"
    "syncthing"
    "tor-browser"
    "tunnelblick"
    "ubersicht"
    "unity"
    "unity-hub"
    "utm"
    "vimac"
    "vnc-viewer"
    "zoom"
  ];
  user_mas_apps = {
    DaisyDisk = 411643860;
    Vimari = 1480933944;
    "WiFi Explorer" = 494803304;
    "Reeder 5." = 1529448980;
    "Okta Extension App" = 1439967473;
  };
in {
  nix.package = pkgs.nix;
  nixpkgs.config.allowUnfree = true;

  homebrew = {
    enable = true;
    autoUpdate = true;
    cleanup = "zap";
    brews = user_brew_formulae;
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = user_brew_taps;
    casks = user_brew_casks;
    masApps = user_mas_apps;
  };
 
  users.users.${user_name} = {
    description = "${user_description}";
    home = "/Users/${user_name}";
    name = "${user_full_name}";
    packages = user_packages;
  };
}
