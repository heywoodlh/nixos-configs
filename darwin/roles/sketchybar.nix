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
  mic-sh = pkgs.writeShellScriptBin "mic.sh" ''
    MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')
    if [[ $MIC_VOLUME -eq 0 ]]; then
      sketchybar -m --set mic icon=
    elif [[ $MIC_VOLUME -gt 0 ]]; then
      sketchybar -m --set mic icon=
    fi
  '';
  mic-click-sh = pkgs.writeShellScriptBin "mic-click.sh" ''
    MIC_VOLUME=$(osascript -e 'input volume of (get volume settings)')
    if [[ $MIC_VOLUME -eq 0 ]]; then
      osascript -e 'set volume input volume 25'
      sketchybar -m --set mic icon=
    elif [[ $MIC_VOLUME -gt 0 ]]; then
      osascript -e 'set volume input volume 0'
      sketchybar -m --set mic icon=
    fi
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
          topmost=off

      ############## GLOBAL DEFAULTS ##############
        sketchybar -m --default \
          updates=when_shown \
          drawing=on \
          cache_scripts=on \
          icon.font="JetBrainsMono Nerd Font Mono:Bold:14.0" \
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
          --set code click_script="${pkgs.yabai}/bin/yabai -m space --focus 2" \

        # SPACE 3: MUSIC ICON
        sketchybar -m --add space music left \
          --set music icon= \
          --set music icon.highlight_color=0xff8CABC8 \
          --set music associated_display=1 \
          --set music associated_space=5 \
          --set music icon.padding_left=5 \
          --set music icon.padding_right=5 \
          --set music label.padding_right=0 \
          --set music label.padding_left=0 \
          --set music label.color=0xffeceff4 \
          --set music background.color=0xff57627A  \
          --set music background.height=21 \
          --set music background.padding_left=7 \
          --set music click_script="open -a Spotify.app" \

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

        # MIC STATUS
        sketchybar -m --add item mic right \
          --set mic icon.padding_left=8 \
          --set mic icon.padding_right=8 \
          --set mic label.padding_right=0 \
          --set mic label.padding_left=0 \
          --set mic label.color=0xffeceff4 \
          --set mic background.color=0xff57627A  \
          --set mic background.height=21 \
          --set mic background.padding_right=7 \
          --set mic update_freq=3 \
          --set mic script="${mic-sh}/bin/mic.sh" \
          --set mic click_script="${mic-click-sh}/bin/mic-click.sh"

        # TOP PROCESS
        sketchybar -m --add item topproc right \
          --set topproc drawing=off \
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
