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
  sync-mail-core = pkgs.writeShellScript "sync-mail-core" ''
    set -euo pipefail
    umask 077
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/mbsync"
    limit_file="$state_dir/protonmail-max-messages"
    config_file="''${XDG_CONFIG_HOME:-$HOME/.config}/isyncrc"
    set_limit() {
      state_file="$(mktemp "$state_dir/protonmail-max-messages.XXXXXX")"
      printf '%s\n' "$1" > "$state_file"
      mv "$state_file" "$limit_file"
    }
    case "''${1:-poll}" in
      poll)
        [[ -s "$limit_file" ]] || set_limit 250
        sync_args=(--all)
        ;;
      backfill)
        limit="$(<"$limit_file")"
        [[ "$limit" =~ ^[0-9]+$ ]] || { echo "Invalid Proton Mail sync limit" >&2; exit 1; }
        set_limit "$((limit + 250))"
        sync_args=(--old --all)
        ;;
      *)
        echo "Unknown Proton Mail sync mode" >&2
        exit 1
        ;;
    esac
    limit="$(<"$limit_file")"
    [[ "$limit" =~ ^[0-9]+$ ]] || { echo "Invalid Proton Mail sync limit" >&2; exit 1; }
    [[ -r "$config_file" ]] || { echo "Missing mbsync configuration" >&2; exit 1; }
    temporary_config="$(mktemp)"
    trap 'rm -f "$temporary_config"' EXIT
    printf 'MaxMessages %s\nExpireUnread yes\n\n' "$limit" > "$temporary_config"
    cat "$config_file" >> "$temporary_config"
    ${pkgs.isync}/bin/mbsync -c "$temporary_config" "''${sync_args[@]}"
    ${pkgs.notmuch}/bin/notmuch new
  '';
  sync-mail = pkgs.writeShellScriptBin "sync-mail" ''
    set -euo pipefail
    umask 077
    state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/mbsync"
    mkdir -p -m 700 "$state_dir"
    exec ${pkgs.perl}/bin/perl -MFcntl=:flock,F_SETFD -e '
      open my $lock, ">>", shift @ARGV or die "Unable to open Proton Mail sync lock: $!\n";
      flock $lock, LOCK_EX | LOCK_NB or exit 0;
      fcntl($lock, F_SETFD, 0) or die "Unable to retain Proton Mail sync lock: $!\n";
      exec @ARGV or die "Unable to start Proton Mail sync: $!\n";
    ' "$state_dir/protonmail-sync.lock" ${sync-mail-core} "$@"
  '';
  backfill-mail = pkgs.writeShellScriptBin "backfill-mail" ''
    exec ${sync-mail}/bin/sync-mail backfill
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

    programs.aerc.extraAccounts = lib.optionalAttrs cfg.accounts {
      protonmail = {
        source = "notmuch://";
        maildir-account-path = "protonmail";
        outgoing = "smtp+insecure://l.spencer.heywood%40protonmail.com@protonmail-bridge.barn-banana.ts.net:25";
        outgoing-cred-cmd = "${cred}";
        default = "INBOX";
        copy-to = "Sent";
        postpone = "Drafts";
        archive = "Archive";
        from = "Spencer Heywood <spencer@heywoodlh.io>";
        aliases = "Spencer Heywood <*@protonmail.com>,Spencer Heywood <*@pm.me>,LaMar Heywood <wgu@heywoodlh.io>,Spencer Heywood <heywoodlh@heywoodlh.io>";
        check-mail = "5s";
        check-mail-cmd = "${sync-mail}/bin/sync-mail";
        check-mail-timeout = "4m";
        signature-file = "${pkgs.writeText "signature.txt" "- L. Spencer Heywood"}";
        address-book-cmd = "${pkgs.khard}/bin/khard email -a personal --parsable --remove-first-line %s";
      };
    };

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
      };
    };

    systemd.user.services.protonmail-backfill = lib.mkIf (cfg.accounts && pkgs.stdenv.hostPlatform.isLinux) {
      Unit.Description = "Progressively backfill Proton Mail";
      Service = {
        Type = "oneshot";
        ExecStart = "${backfill-mail}/bin/backfill-mail";
      };
    };
    systemd.user.timers.protonmail-backfill = lib.mkIf (cfg.accounts && pkgs.stdenv.hostPlatform.isLinux) {
      Unit.Description = "Progressively backfill Proton Mail";
      Timer = {
        OnBootSec = "10min";
        OnUnitActiveSec = "10min";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    launchd.agents.protonmail-backfill = lib.mkIf (cfg.accounts && pkgs.stdenv.hostPlatform.isDarwin) {
      enable = true;
      config = {
        ProgramArguments = [ "${backfill-mail}/bin/backfill-mail" ];
        RunAtLoad = false;
        StartInterval = 600;
        ProcessType = "Background";
      };
    };

    home.activation.protonmail-sync-limit = lib.mkIf cfg.accounts ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/mbsync"
      limit_file="$state_dir/protonmail-max-messages"
      mkdir -p -m 700 "$state_dir"
      if [[ ! -s "$limit_file" ]]
      then
        state_file="$(mktemp "$state_dir/protonmail-max-messages.XXXXXX")"
        printf '250\n' > "$state_file"
        mv "$state_file" "$limit_file"
      fi
    '';

    home.packages = with pkgs; [
      khard
      sync-mail
      backfill-mail
    ];

    home.file.".config/khard/khard.conf".text = lib.optionalString (cfg.accounts) ''
      [addressbooks]
      [[personal]]
      path = ~/.contacts/apple/main
    '';
  };
}
