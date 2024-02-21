{ config, pkgs, home-manager, hyprland, ... }:

# Resources for laptops running Hyprland
let
  homeDir = config.home.homeDirectory;
  laptop_display = "eDP-1";
in {
  home.packages = with pkgs; [
    coreutils
    gnugrep
    jq
  ];

  home.file."bin/clamshell.sh" = {
    text = ''
      #!/usr/bin/env bash
      ## Some variables to use in the script
      export laptop_display="${laptop_display}"
      export lid_open="false"
      export laptop_display_enabled="false"

      # Check if laptop lid open
      ${pkgs.gnugrep}/bin/grep -q open /proc/acpi/button/lid/LID0/state && export lid_open="true"

      # Check if external monitors connected
      num_displays=$(hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | .name' | ${pkgs.gnugrep}/bin/grep -v $laptop_display | ${pkgs.coreutils}/bin/wc -l)
      [[ $num_displays -gt 0 ]] && external_displays="true"

      # If external displays are connected, and the laptop lid is not open
      # Turn off the laptop display
      [[ $external_displays == "true" && $lid_open == "false" ]] && hyprctl keyword monitor "$laptop_display,disable"

      # If laptop lid is open, make sure it is enabled
      if [[ $lid_open == "true" ]]
      then
        # If laptop display is not enabled, then re-enable
        if ! hyprctl monitors -j | ${pkgs.jq}/bin/jq '.[] | .name' | ${pkgs.gnugrep}/bin/grep -q $laptop_display
        then
          hyprctl keyword monitor "$laptop_display,preferred,auto,1"
          hyprctl reload
        fi
      fi
    '';
    executable = true;
  };

  wayland.windowManager.hyprland.extraConfig = ''
    bindl = , switch:Lid Switch, exec, ${homeDir}/bin/clamshell.sh
  '';
}
