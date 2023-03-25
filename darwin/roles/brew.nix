{ config, ... }:

{
  #homebrew packages
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [
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
      "bitwarden-cli"
      "choose-gui"
      "clamav"
      "cliclick"
      "coreutils"
      "croc"
      "curl"
      "dante"
      "dos2unix"
      "ffmpeg"
      "findutils"
      "fzf"
      "gcc"
      "gitleaks"
      "glib"
      "glow"
      "gnupg"
      "gnu-sed"
      "gh"
      "git"
      "go"
      "gomuks"
      "harfbuzz"
      "hashcat"
      "helm"
      "htop"
      "jailkit"
      "jq"
      "jwt-cli"
      "k9s"
      "kdash"
      "kind"
      "kompose"
      "kubectl"
      "lefthook"
      "libolm"
      "lima"
      "m-cli"
      "mas"
      "mosh"
      "neofetch"
      "neovim"
      "node"
      "openssl@3"
      "pandoc"
      "pass"
      "pass-otp"
      "pinentry-mac"
      "popeye"
      "pre-commit"
      "proxychains-ng"
      "pulumi"
      "pwgen"
      "python"
      "rbw"
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
    extraConfig = ''
      cask_args appdir: "~/Applications"
    '';
    taps = [
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
      "aaronraimist/homebrew-tap"
      "kdash-rs/kdash"
    ];
    casks = [
      "android-platform-tools"
      "beeper"
      "bitwarden"
      "blockblock"
      "brave-browser"
      "caffeine"
      "cursorcerer"
      "discord"
      "element"
      "docker"
      "firefox"
      "font-droid-sans-mono-for-powerline"
      "font-iosevka-nerd-font"
      "font-jetbrains-mono-nerd-font"
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
      "powershell"
      "raycast"
      "reikey"
      "rustdesk"
      "screens"
      "secretive"
      "session"
      "signal"
      "slack"
      "syncthing"
      "tageditor"
      "tor-browser"
      "tunnelblick"
      "ubersicht"
      "utm"
      "vnc-viewer"
      "zoom"
    ];
    masApps = {
      DaisyDisk = 411643860;
      Vimari = 1480933944;
      "WiFi Explorer" = 494803304;
      "Reeder 5." = 1529448980;
      "Okta Extension App" = 1439967473;
    };
  };
}
