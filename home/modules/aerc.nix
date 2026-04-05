{ config, lib, pkgs, myFlakes, ... }:

with lib;

let
  cfg = config.heywoodlh.home.aerc;
  system = pkgs.stdenv.hostPlatform.system;
  op-wrapper = "${myFlakes.packages.${system}.op-wrapper}/bin/op-wrapper";
  aerc-html-filter = pkgs.writeShellScript "html" ''
    export SOCKS_SERVER="10.64.0.1:1080"
    exec ${pkgs.dante}/bin/socksify ${pkgs.w3m}/bin/w3m \
      -T text/html \
      -cols $(${pkgs.ncurses}/bin/tput cols) \
      -dump \
      -o display_image=false \
      -o display_link_number=true
  '';
  cred = pkgs.writeShellScript "cred.sh" ''
    mkdir -p ~/.config/aerc
    if [[ ! -e ~/.config/aerc/protonmail.txt ]]
    then
      ${op-wrapper} read 'op://Personal/7xgfk5ve2zeltpeyglwephqtsq/bridge' > ~/.config/aerc/protonmail.txt
    fi
    if [[ -e ~/.config/aerc/protonmail.txt ]]
    then
      cat ~/.config/aerc/protonmail.txt
    else
      echo "Unable to populate credentials. Exiting."
      exit 1
    fi
  '';
in {
  options = {
    heywoodlh.home.aerc = {
      enable = mkOption {
        default = false;
        description = ''
          Enable heywoodlh aerc configuration.
        '';
        type = types.bool;
      };
      accounts = mkOption {
        default = false;
        description = ''
          Enable heywoodlh aerc accounts. Only useful to the author.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    heywoodlh.home.helix.enable = true;

    programs.aerc.enable = true;
    programs.aerc.extraConfig = {
      general = {
        unsafe-accounts-conf = true;
        editor = "hx";
      };
      filters = {
        "text/html" = "${aerc-html-filter}";
        "text/plain" = "${pkgs.coreutils}/bin/fold -w 80";
      };
    };
    programs.aerc.extraAccounts = lib.optionalAttrs (cfg.accounts) {
      protonmail = {
        source = "imap+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:143";
        source-cred-cmd = "${cred}";
        outgoing = "smtp+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:25";
        outgoing-cred-cmd = "${cred}";
        default = "INBOX";
        copy-to = "Sent";
        from = "Spencer Heywood <spencer@heywoodlh.io>";
        aliases = "Spencer Heywood <*@protonmail.com>,Spencer Heywood <*@pm.me>, Spencer Heywood <heywoodlh@heywoodlh.io>";
        signature-file = "${pkgs.writeText "signature.txt" "- Spencer"}";
        address-book-cmd = "${pkgs.khard}/bin/khard email -a personal --parsable --remove-first-line %s";
      };
    };

    home.packages = with pkgs; lib.optionals (cfg.accounts) [
      khard
    ];

    home.file.".config/khard/khard.conf".text = lib.optionalString (cfg.accounts) ''
      [addressbooks]
      [[personal]]
      path = ~/.contacts/apple/main
    '';
  };
}
