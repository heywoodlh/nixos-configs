{ config, pkgs, ... }:

{
  services.yabai.enable = true;
  services.yabai.package = pkgs.yabai;
  services.yabai.enableScriptingAddition = false;
  services.yabai.extraConfig = ''
    yabai -m config window_placement             first_child
    yabai -m config window_topmost               off
    yabai -m config window_opacity               off
    yabai -m config window_opacity_duration      0.0
    yabai -m config window_shadow                on
    yabai -m config window_border                off
    yabai -m config window_border_width          4
    yabai -m config active_window_border_color   0xff775759
    yabai -m config normal_window_border_color   0xff505050
    yabai -m config active_window_opacity        1.0
    yabai -m config normal_window_opacity        0.90
    yabai -m config split_ratio                  0.50
    yabai -m config auto_balance                 off
    yabai -m config mouse_modifier               fn
    yabai -m config mouse_action1                move
    yabai -m config mouse_action2                resize

    yabai -m config layout                       bsp
    yabai -m config top_padding                  10
    yabai -m config external_bar                 all:30:0
    yabai -m config bottom_padding               10
    yabai -m config left_padding                 20
    yabai -m config right_padding                20
    yabai -m config window_gap                   10

    yabai -m signal --add event=window_destroyed \
      action="''\'''${functions[focus_under_cursor]}"
    yabai -m signal --add event=window_minimized \
      action="''\'''${functions[focus_under_cursor]}"
    yabai -m signal --add event=application_hidden \
      action="''\'''${functions[focus_under_cursor]}"

    function focus_under_cursor {
      if yabai -m query --windows --space |
          jq -er 'map(select(.focused == 1)) | length == 0' >/dev/null; then
        yabai -m window --focus mouse 2>/dev/null || true
      fi
    }

    # Custom stuff
    ## Unmanaged apps
    yabai -m rule --add app="/usr/local/bin/choose" manage=off
    yabai -m rule --add app="/opt/homebrew/bin/choose" manage=off
    yabai -m rule --add app="choose-launcher.sh" manage=off
    yabai -m rule --add app="choose" manage=off
    yabai -m rule --add app="/usr/local/bin/pinentry-mac" manage=off
    yabai -m rule --add app="/opt/homebrew/bin/pinentry-mac" manage=off
    yabai -m rule --add app="pinentry-mac" manage=off
    yabai -m rule --add app="^System Preferences$" manage=off
    yabai -m rule --add app="/Applications/Secretive.app/Contents/MacOS/Secretive" manage=off
  '';
}
