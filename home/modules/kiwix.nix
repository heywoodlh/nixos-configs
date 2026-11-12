{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.kiwix;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  kiwix-cli = pkgs.callPackage ../../pkgs/kiwix-cli.nix {};
  # ServerNegativeTest.UnusablePort fails on macOS, where unprivileged users can bind low ports
  kiwix-tools = if isDarwin then pkgs.kiwix-tools.override {
    libkiwix = pkgs.libkiwix.overrideAttrs { doCheck = false; };
  } else pkgs.kiwix-tools;

  cronFields = filter isString (builtins.split "[[:space:]]+" (strings.trim cfg.cron));

  expandItem = min: max: item: let
    stepParts = splitString "/" item;
    rangePart = elemAt stepParts 0;
    step = if length stepParts > 1 then toInt (elemAt stepParts 1) else 1;
    bounds =
      if rangePart == "*" then [ min max ]
      else if hasInfix "-" rangePart then map toInt (splitString "-" rangePart)
      else if length stepParts > 1 then [ (toInt rangePart) max ]
      else [ (toInt rangePart) (toInt rangePart) ];
    lo = elemAt bounds 0;
    hi = elemAt bounds 1;
  in filter (n: mod (n - lo) step == 0) (range lo hi);

  expandField = min: max: field:
    if field == "*" then null
    else unique (concatMap (expandItem min max) (splitString "," field));

  minutes = expandField 0 59 (elemAt cronFields 0);
  hours = expandField 0 23 (elemAt cronFields 1);
  doms = expandField 1 31 (elemAt cronFields 2);
  months = expandField 1 12 (elemAt cronFields 3);
  dows = expandField 0 7 (elemAt cronFields 4);

  listOrWildcard = l: if l == null then "*" else concatMapStringsSep "," toString l;
  dowNames = [ "Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun" ];
  dowPrefix = if dows == null then "" else "${concatMapStringsSep "," (n: elemAt dowNames n) dows} ";
  onCalendar = "${dowPrefix}*-${listOrWildcard months}-${listOrWildcard doms} ${listOrWildcard hours}:${listOrWildcard minutes}:00";

  calendarIntervals = foldl' (acc: dim:
    if dim.values == null then acc
    else concatMap (entry: map (value: entry // { ${dim.key} = value; }) dim.values) acc
  ) [ {} ] [
    { key = "Minute"; values = minutes; }
    { key = "Hour"; values = hours; }
    { key = "Day"; values = doms; }
    { key = "Month"; values = months; }
    { key = "Weekday"; values = dows; }
  ];

  download = pkgs.writeShellApplication {
    name = "kiwix-download";
    runtimeInputs = [ pkgs.coreutils pkgs.curl pkgs.gawk ];
    text = ''
      dir="${cfg.dir}"
      urls=(${concatMapStringsSep " " escapeShellArg cfg.urls})
      failed=0

      remote_size() {
        curl -fsSIL --retry 3 --connect-timeout 30 "$1" | tr -d '\r' | awk 'tolower($1) == "content-length:" { size = $2 } END { print size }'
      }

      is_dated_zim() {
        case "$1" in
          [0-9][0-9][0-9][0-9]-[0-9][0-9].zim | [0-9][0-9][0-9][0-9]-[0-9][0-9][a-z].zim) return 0 ;;
          *) return 1 ;;
        esac
      }

      prune_superseded() {
        local name="$1"
        local stem="''${name%_*}"
        local old suffix
        for old in "$dir/''${stem}_"*.zim; do
          [ -e "$old" ] || continue
          [ "$old" = "$dir/$name" ] && continue
          suffix="''${old##*/}"
          suffix="''${suffix#"''${stem}"_}"
          if is_dated_zim "$suffix"; then
            echo "Removing superseded $old"
            rm -f "$old"
          fi
        done
      }

      if [ "''${#urls[@]}" -eq 0 ]; then
        echo "No ZIM URLs configured"
        exit 0
      fi

      umask 022
      mkdir -p "$dir"

      for url in "''${urls[@]}"; do
        name="''${url##*/}"
        dest="$dir/$name"
        part="$dest.part"

        size="$(remote_size "$url" || true)"
        if [ -z "$size" ]; then
          echo "ERROR: could not determine size of $url"
          failed=$((failed + 1))
          continue
        fi

        if [ -f "$dest" ] && [ "$(wc -c < "$dest")" = "$size" ]; then
          echo "Up to date: $name"
          prune_superseded "$name"
          continue
        fi

        if [ -f "$part" ] && [ "$(wc -c < "$part")" -gt "$size" ]; then
          rm -f "$part"
        fi

        echo "Downloading $name ($size bytes)"
        if curl -fL --no-progress-meter --show-error --retry 5 --retry-delay 15 --connect-timeout 30 --speed-limit 1024 --speed-time 120 -C - -o "$part" "$url" \
          && [ "$(wc -c < "$part")" = "$size" ]; then
          mv -f "$part" "$dest"
          prune_superseded "$name"
        else
          echo "ERROR: failed to download $url"
          failed=$((failed + 1))
        fi
      done

      if [ "$failed" -gt 0 ]; then
        echo "$failed download(s) failed"
        exit 1
      fi
      echo "All ZIM files are up to date"
    '';
  };

  tui = pkgs.writeShellApplication {
    name = "kiwix-tui";
    runtimeInputs = [ pkgs.coreutils pkgs.curl pkgs.findutils kiwix-tools kiwix-cli ];
    text = ''
      dir="${cfg.dir}"
      mapfile -t zims < <(find "$dir" -type f -name '*.zim' | sort)
      if [ "''${#zims[@]}" -eq 0 ]; then
        echo "No ZIM files in $dir (run kiwix-download)"
        exit 1
      fi

      port=$((49152 + RANDOM % 16000))
      while (exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null; do
        port=$((49152 + RANDOM % 16000))
      done

      kiwix-serve --address=127.0.0.1 --port="$port" "''${zims[@]}" >/dev/null 2>&1 &
      server=$!
      trap 'kill "$server" 2>/dev/null || true' EXIT

      for _ in $(seq 1 60); do
        if curl -fs "http://127.0.0.1:$port/catalog/v2/root.xml" >/dev/null 2>&1; then
          break
        fi
        sleep 0.5
      done

      KIWIX_URL="http://127.0.0.1:$port" kiwix-cli "$@"
    '';
  };
in {
  options.heywoodlh.home.kiwix = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh Kiwix configuration.
      '';
      type = types.bool;
    };
    urls = mkOption {
      default = [];
      description = ''
        ZIM file URLs to download periodically. Files already downloaded with
        a matching size are skipped.
      '';
      type = types.listOf types.str;
    };
    dir = mkOption {
      default = "$HOME/Documents/kiwix";
      description = ''
        Directory ZIM files are downloaded to and read from by Kiwix and the
        TUI reader. Shell variables such as $HOME are expanded at runtime.
      '';
      type = types.str;
    };
    cron = mkOption {
      default = "0 * * * *";
      description = ''
        Five-field cron expression (minute hour day-of-month month
        day-of-week) controlling when ZIM files are downloaded. Supports `*`,
        lists, ranges and steps. Translated into a systemd timer on Linux and
        a launchd calendar interval on macOS. Day-of-month and day-of-week
        restrictions are combined (AND), unlike classic cron.
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = length cronFields == 5;
        message = "heywoodlh.home.kiwix.cron must have five fields, got: ${cfg.cron}";
      }
    ];

    home.packages = [
      download
      tui
      kiwix-cli
    ] ++ optional isLinux pkgs.kiwix
      ++ optional isDarwin pkgs.kiwix-apple;

    home.activation.kiwixDesktop = mkIf isLinux ''
      dir="${cfg.dir}"
      conf="${config.xdg.configHome}/Kiwix/Kiwix-desktop.conf"
      run mkdir -p "$dir" "$(dirname "$conf")"
      run ${pkgs.crudini}/bin/crudini --set "$conf" download dir "$dir"
      run ${pkgs.crudini}/bin/crudini --set "$conf" monitor dir "$dir"
    '';

    home.activation.kiwixDir = mkIf isDarwin ''
      run mkdir -p "${cfg.dir}"
    '';

    systemd.user.services.kiwix-download = mkIf isLinux {
      Unit = {
        Description = "Download Kiwix ZIM files";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${download}/bin/kiwix-download";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };

    systemd.user.timers.kiwix-download = mkIf isLinux {
      Unit.Description = "Download Kiwix ZIM files on a schedule";
      Timer = {
        OnCalendar = onCalendar;
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    launchd.agents.kiwix-download = mkIf isDarwin {
      enable = true;
      config = {
        ProgramArguments = [ "${download}/bin/kiwix-download" ];
        StartCalendarInterval = calendarIntervals;
        RunAtLoad = true;
        ProcessType = "Background";
        LowPriorityIO = true;
        StandardOutPath = "${config.home.homeDirectory}/Library/Logs/kiwix-download.log";
        StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/kiwix-download.log";
      };
    };
  };
}
