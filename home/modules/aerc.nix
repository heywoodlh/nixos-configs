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
    umask 077
    mkdir -p ~/.config/aerc

    # Remove file if empty
    [[ -s ~/.config/aerc/protonmail.txt ]] || rm -f ~/.config/aerc/protonmail.txt

    if [[ ! -e ~/.config/aerc/protonmail.txt ]]
    then
      credential_file="$(mktemp ~/.config/aerc/protonmail.txt.XXXXXX)"
      trap 'rm -f "$credential_file"' EXIT
      if ! ${op-wrapper} read 'op://Personal/7xgfk5ve2zeltpeyglwephqtsq/bridge' > "$credential_file" || [[ ! -s "$credential_file" ]]
      then
        echo "Unable to populate credentials. Exiting." >&2
        exit 1
      fi
      mv "$credential_file" ~/.config/aerc/protonmail.txt
      trap - EXIT
    fi
    if [[ -s ~/.config/aerc/protonmail.txt ]]
    then
      chmod 600 ~/.config/aerc/protonmail.txt
      cat ~/.config/aerc/protonmail.txt
    else
      echo "Unable to populate credentials. Exiting." >&2
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
    programs.mbsync.enable = cfg.accounts;
    programs.notmuch.enable = cfg.accounts;

    accounts.email = lib.mkIf cfg.accounts {
      maildirBasePath = "${config.home.homeDirectory}/.mail";
      accounts.protonmail = {
        enable = true;
        primary = true;
        address = "spencer@heywoodlh.io";
        realName = "Spencer Heywood";
        userName = "l.spencer.heywood@protonmail.com";
        aliases = [ "*@protonmail.com" "*@pm.me" "wgu@heywoodlh.io" "heywoodlh@heywoodlh.io" ];
        passwordCommand = [ "${cred}" ];
        imap = {
          host = "protonmail-bridge.barn-banana.ts.net";
          port = 143;
          tls.enable = false;
        };
        smtp = {
          host = "protonmail-bridge.barn-banana.ts.net";
          port = 25;
          tls.enable = false;
        };
        mbsync = {
          enable = true;
          create = "maildir";
          patterns = [ "INBOX" "Archive" "Sent" "Drafts" ];
        };
        notmuch.enable = true;
        aerc = {
          enable = true;
          extraAccounts = {
            archive = "Archive";
            signature-file = "${pkgs.writeText "signature.txt" "- L. Spencer Heywood"}";
            address-book-cmd = "${pkgs.khard}/bin/khard email -a personal --parsable --remove-first-line %s";
          };
        };
      };
    };

    home.packages = with pkgs; [
      khard
    ];

    home.file.".config/khard/khard.conf".text = lib.optionalString (cfg.accounts) ''
      [addressbooks]
      [[personal]]
      path = ~/.contacts/apple/main
    '';
  };
}
