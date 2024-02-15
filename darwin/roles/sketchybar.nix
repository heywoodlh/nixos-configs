{ config, pkgs, ... }:

let
  space-sh = pkgs.writeShellScriptBin "space.sh" ''
    if [ "$SELECTED" = "true" ]
    then
      sketchybar -m --set $NAME background.color=0xff81a1c1
    else
      sketchybar -m --set $NAME background.color=0xff57627A
    fi
  '';
  window-title-sh = pkgs.writeShellScriptBin "window_title.sh" ''
    WINDOW_TITLE=$(${pkgs.yabai}/bin/yabai -m query --windows --window | ${pkgs.jq}/bin/jq -r '.app')
    if [[ $WINDOW_TITLE != "" ]]; then
      sketchybar -m --set title label="$WINDOW_TITLE"
    else
      sketchybar -m --set title label=None
    fi
  '';
  date-time-sh = pkgs.writeShellScriptBin "date-time.sh" ''
    sketchybar -m --set $NAME label="$(date '+%a %d %b %H:%M')"
  '';
  top-mem-sh = pkgs.writeShellScriptBin "top-mem.sh" ''
    TOPPROC=$(ps axo "%cpu,ucomm" | sort -nr | tail +1 | head -n1 | awk '{printf "%.0f%% %s\n", $1, $2}' | sed -e 's/com.apple.//g')
    TOPMEM=$(ps axo "rss" | sort -nr | tail +1 | head -n1 | awk '{printf "%.0fMB %s\n", $1 / 1024, $2}' | sed -e 's/com.apple.//g')
    MEM=$(echo $TOPMEM | sed -nr 's/([^MB]+).*/\1/p')
    sketchybar -m --set $NAME label="$TOPMEM"
  '';
  cpu-sh = pkgs.writeShellScriptBin "cpu.sh" ''
    CORE_COUNT=$(sysctl -n machdep.cpu.thread_count)
    CPU_INFO=$(ps -eo pcpu,user)
    CPU_SYS=$(echo "$CPU_INFO" | grep -v $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
    CPU_USER=$(echo "$CPU_INFO" | grep $(whoami) | sed "s/[^ 0-9\.]//g" | awk "{sum+=\$1} END {print sum/(100.0 * $CORE_COUNT)}")
    sketchybar -m --set  cpu_percent label=$(echo "$CPU_SYS $CPU_USER" | awk '{printf "%.0f\n", ($1 + $2)*100}')%
  '';
  caffeine-sh = pkgs.writeShellScriptBin "caffeine.sh" ''
    if pgrep -q 'caffeinate'
    then
      sketchybar --set $NAME icon="󰅶"
    else
      sketchybar --set $NAME icon="󰛊"
    fi
  '';
  caffeine-click-sh = pkgs.writeShellScriptBin "caffeine-click.sh" ''
    if pgrep -q 'caffeinate'
    then
      killall caffeinate
      sketchybar --set $NAME icon="󰛊"
    else
      caffeinate -d & disown
      sketchybar --set $NAME icon="󰅶"
    fi
  '';
  battery-sh = pkgs.writeShellScriptBin "battery.sh" ''
    data=$(pmset -g batt)
    battery_percent=$(echo $data | grep -Eo "\d+%" | cut -d% -f1)
    charging=$(echo $data | grep 'AC Power')

    case "$battery_percent" in
        100)    icon="󰁹" color=0xFFFFFFFF ;;
        9[0-9]) icon="󰂂" color=0xFFFFFFFF ;;
        8[0-9]) icon="󰂁" color=0xFFFFFFFF ;;
        7[0-9]) icon="󰂀" color=0xFFFFFFFF ;;
        6[0-9]) icon="󰁿" color=0xFFFFFFFF ;;
        5[0-9]) icon="󰁾" color=0xFFFFFFFF ;;
        4[0-9]) icon="󰁽" color=0xFFFFFFFF ;;
        3[0-9]) icon="󰁼" color=0xFFFFFFFF ;;
        2[0-9]) icon="󰁻" color=0xFFFFFFFF ;;
        1[0-9]) icon="󰁺" color=0xFFFFFFFF ;;
        *)      icon="󰂃" color=0xFFFFFFFF ;;
    esac

    # if is charging
    if ! [ -z "$charging" ]; then
        icon="$icon"
    fi

    sketchybar \
        --set $NAME \
            icon.color="$color" \
            icon="$icon" \
            label="$battery_percent%"
  '';
  top-proc-sh = pkgs.writeShellScriptBin "top-proc.sh" ''
    TOPPROC=$(ps axo "%cpu,ucomm" | sort -nr | tail +1 | head -n1 | awk '{printf "%.0f%% %s\n", $1, $2}' | sed -e 's/com.apple.//g')
    CPUP=$(echo $TOPPROC | sed -nr 's/([^\%]+).*/\1/p')
    if [ $CPUP -gt 75 ]; then
      sketchybar -m --set $NAME label="$TOPPROC"
    else
      sketchybar -m --set $NAME label=""
    fi
  '';
  spotify-indicator-sh = pkgs.writeShellScriptBin "spotify-indicator.sh" ''
    RUNNING="$(osascript -e 'if application "Spotify" is running then return 0')"
    if [ $RUNNING != 0 ]
    then
      RUNNING=1
    fi
    PLAYING=1
    TRACK=""
    ALBUM=""
    ARTIST=""
    if [[ $RUNNING -eq 0 ]]
    then
      [[ "$(osascript -e 'if application "Spotify" is running then tell application "Spotify" to get player state')" == "playing" ]] && PLAYING=0
      TRACK="$(osascript -e 'tell application "Spotify" to get name of current track')"
      ARTIST="$(osascript -e 'tell application "Spotify" to get artist of current track')"
      ALBUM="$(osascript -e 'tell application "Spotify" to get album of current track')"
    fi
    if [[ -n "$TRACK" ]]
    then
      sketchybar -m --set "$NAME" drawing=on
      [[ "$PLAYING" -eq 0 ]] && ICON=""
      [[ "$PLAYING" -eq 1 ]] && ICON=""
      if [ "$ARTIST" == "" ]
      then
        sketchybar -m --set "$NAME" label="''${ICON} ''${TRACK} - ''${ALBUM}"
      else
        sketchybar -m --set "$NAME" label="''${ICON} ''${TRACK} - ''${ARTIST}"
      fi
    else
      sketchybar -m --set "$NAME" label="" drawing=off
    fi
  '';
in {
  services.sketchybar = {
    enable = true;
    extraPackages = with pkgs; [
      jetbrains-mono
    ];
    config = ''
      ############## BAR ##############
        sketchybar -m --bar \
          height=32 \
          position=top \
          padding_left=5 \
          padding_right=5 \
          color=0xff3b4252 \
          shadow=off \
          sticky=on \
          topmost=off

      ############## GLOBAL DEFAULTS ##############
        sketchybar -m --default \
          updates=when_shown \
          drawing=on \
          cache_scripts=on \
          icon.font="JetBrainsMono Nerd Font Mono:Bold:18.0" \
          icon.color=0xffffffff \
          label.font="JetBrainsMono Nerd Font Mono:Bold:12.0" \
          label.color=0xffeceff4 \
          label.highlight_color=0xff8CABC8

      ############## SPACE DEFAULTS ##############
        sketchybar -m --default \
          label.padding_left=5 \
          label.padding_right=2 \
          icon.padding_left=8 \
          label.padding_right=8

      ############## PRIMARY DISPLAY SPACES ##############
        # APPLE ICON
        sketchybar -m --add item apple left \
          --set apple icon= \
          --set apple icon.font="JetBrainsMono Nerd Font Mono:Regular:20.0" \
          --set apple label.padding_right=0 \

        # SPACE 1: WEB ICON
        sketchybar -m --add space web left \
          --set web icon= \
          --set web icon.highlight_color=0xff8CABC8 \
          --set web associated_space=1 \
          --set web icon.padding_left=5 \
          --set web icon.padding_right=5 \
          --set web label.padding_right=0 \
          --set web label.padding_left=0 \
          --set web label.color=0xffeceff4 \
          --set web background.color=0xff57627A  \
          --set web background.height=21 \
          --set web background.padding_left=12 \
          --set web click_script="open -a Firefox.app" \

        # SPACE 2: CODE ICON
        sketchybar -m --add space code left \
          --set code icon= \
          --set code associated_space=2 \
          --set code icon.padding_left=5 \
          --set code icon.padding_right=5 \
          --set code label.padding_right=0 \
          --set code label.padding_left=0 \
          --set code label.color=0xffeceff4 \
          --set code background.color=0xff57627A  \
          --set code background.height=21 \
          --set code background.padding_left=7 \
          --set code click_script="$HOME/.nix-profile/bin/wezterm" \

        # SPACE 3: MUSIC ICON
        #sketchybar -m --add space music left \
        #  --set music icon= \
        #  --set music icon.highlight_color=0xff8CABC8 \
        #  --set music associated_display=1 \
        #  --set music associated_space=5 \
        #  --set music icon.padding_left=5 \
        #  --set music icon.padding_right=5 \
        #  --set music label.padding_right=0 \
        #  --set music label.padding_left=0 \
        #  --set music label.color=0xffeceff4 \
        #  --set music background.color=0xff57627A  \
        #  --set music background.height=21 \
        #  --set music background.padding_left=7 \
        #  --set music click_script="open -a Spotify.app" \

        # SPOTIFY STATUS
        # CURRENT SPOTIFY SONG
        # Adding custom events which can listen on distributed notifications from other running processes
        #sketchybar -m --add event spotify_change "com.spotify.client.PlaybackStateChanged" \
        #  --add item spotify_indicator left \
        #  --set spotify_indicator background.color=0xff57627A  \
        #  --set spotify_indicator background.height=21 \
        #  --set spotify_indicator background.padding_left=7 \
        #  --set spotify_indicator script="${spotify-indicator-sh}/bin/spotify-indicator.sh" \
        #  --set spotify_indicator click_script="osascript -e 'tell application \"Spotify\" to pause'" \
        #  --subscribe spotify_indicator spotify_change \

      ############## ITEM DEFAULTS ###############
        sketchybar -m --default \
          label.padding_left=2 \
          icon.padding_right=2 \
          icon.padding_left=6 \
          label.padding_right=6

      ############## RIGHT ITEMS ##############
        # DATE TIME
        sketchybar -m --add item date_time right \
          --set date_time icon= \
          --set date_time icon.padding_left=8 \
          --set date_time icon.padding_right=0 \
          --set date_time label.padding_right=9 \
          --set date_time label.padding_left=6 \
          --set date_time label.color=0xffeceff4 \
          --set date_time update_freq=20 \
          --set date_time background.color=0xff57627A \
          --set date_time background.height=21 \
          --set date_time background.padding_right=12 \
          --set date_time script="${date-time-sh}/bin/date-time.sh" \

        # Battery STATUS
        sketchybar -m --add item battery right \
          --set battery icon.font="JetBrainsMono Nerd Font Mono:Bold:10.0" \
          --set battery icon.padding_left=8 \
          --set battery icon.padding_right=8 \
          --set battery label.padding_right=8 \
          --set battery label.padding_left=0 \
          --set battery label.color=0xffffffff \
          --set battery background.color=0xff57627A  \
          --set battery background.height=21 \
          --set battery background.padding_right=7 \
          --set battery update_freq=10 \
          --set battery script="${battery-sh}/bin/battery.sh" \

        # RAM USAGE
        sketchybar -m --add item topmem right \
          --set topmem icon= \
          --set topmem icon.padding_left=8 \
          --set topmem icon.padding_right=0 \
          --set topmem label.padding_right=8 \
          --set topmem label.padding_left=6 \
          --set topmem label.color=0xffeceff4 \
          --set topmem background.color=0xff57627A  \
          --set topmem background.height=21 \
          --set topmem background.padding_right=7 \
          --set topmem update_freq=2 \
          --set topmem script="${top-mem-sh}/bin/top-mem.sh" \

        # CPU USAGE
        sketchybar -m --add item cpu_percent right \
          --set cpu_percent icon= \
          --set cpu_percent icon.padding_left=8 \
          --set cpu_percent icon.padding_right=0 \
          --set cpu_percent label.padding_right=8 \
          --set cpu_percent label.padding_left=6 \
          --set cpu_percent label.color=0xffeceff4 \
          --set cpu_percent background.color=0xff57627A  \
          --set cpu_percent background.height=21 \
          --set cpu_percent background.padding_right=7 \
          --set cpu_percent update_freq=2 \
          --set cpu_percent script="${cpu-sh}/bin/cpu.sh" \

        # CAFFEINE
        sketchybar -m --add item caffeine right \
          --set caffeine icon.padding_left=8 \
          --set caffeine icon.padding_right=0 \
          --set caffeine label.padding_right=0 \
          --set caffeine label.padding_left=6 \
          --set caffeine label.color=0xffeceff4 \
          --set caffeine background.color=0xff57627A  \
          --set caffeine background.height=21 \
          --set caffeine background.padding_right=7 \
          --set caffeine script="${caffeine-sh}/bin/caffeine.sh" \
          --set caffeine click_script="${caffeine-click-sh}/bin/caffeine-click.sh" \

        # TOP PROCESS
        sketchybar -m --add item topproc right \
          --set topproc drawing=on \
          --set topproc label.padding_right=10 \
          --set topproc update_freq=15 \
          --set topproc script="${top-proc-sh}/bin/topproc.sh"

      ###################### CENTER ITEMS ###################


      ############## FINALIZING THE SETUP ##############
      sketchybar -m --update

      echo "sketchybar configuration loaded.."
    '';
  };
}
