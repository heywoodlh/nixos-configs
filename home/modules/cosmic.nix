{ config, lib, pkgs, myFlakes, dark-wallpaper, ... }:

with lib;

let
  cfg = config.heywoodlh.home.cosmic;
  homeDir = config.home.homeDirectory;
  system = pkgs.stdenv.hostPlatform.system;
  myTmux = myFlakes.packages.${system}.tmux;
  myFish = myFlakes.packages.${system}.fish;
in {
  options = {
    heywoodlh.home.cosmic = mkOption {
      default = false;
      description = ''
        Enable heywoodlh cosmic configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.packages = with pkgs; [
      xclip
    ];
    services.unclutter.enable = true;
    xdg.configFile."com.system76.CosmicComp/v1/input_touchpad".text = ''
      (
          state: Enabled,
          scroll_config: Some((
              method: None,
              natural_scroll: Some(true),
              scroll_button: None,
              scroll_factor: None,
          )),
          tap_config: Some((
              enabled: true,
              button_map: Some(LeftRightMiddle),
              drag: true,
              drag_lock: false,
          )),
      )
    '';

    xdg.configFile."cosmic/com.system76.CosmicBackground/v1/all".text = ''
      (
        filter_by_theme: false,
        filter_method: Lanczos,
        output: "all",
        rotation_frequency: 300,
        sampling_method: Alphanumeric,
        scaling_mode: Zoom,
        source: Path("${dark-wallpaper}"),
      )
    '';

    xdg.configFile."cosmic/com.system76.CosmicComp/v1/workspaces".text = ''
      (
          workspace_mode: OutputBound,
          workspace_layout: Horizontal,
      )
    '';

    xdg.configFile."cosmic/com.system76.CosmicComp/v1/xkb_config".text = ''
      (
          rules: "",
          model: "",
          layout: "",
          variant: "",
          options: Some(",caps:super"),
          repeat_delay: 600,
          repeat_rate: 25,
      )
    '';

    xdg.configFile."cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".text = ''
      {
          (
              modifiers: [
                  Super,
                  Shift,
              ],
              key: "s",
          ): System(Screenshot),
          (
              modifiers: [],
              key: "XF86AudioPlay",
          ): Disable,
          (
              modifiers: [
                  Super,
              ],
              key: "space",
          ): System(Launcher),
          (
              modifiers: [
                  Super,
              ],
              key: "bracketright",
          ): Focus(Right),
          (
              modifiers: [
                  Super,
                  Shift,
              ],
              key: "Right",
          ): Disable,
          (
              modifiers: [
                  Ctrl,
                  Shift,
              ],
              key: "space",
          ): System(PlayPause),
          (
              modifiers: [
                  Super,
              ],
              key: "h",
          ): Disable,
          (
              modifiers: [
                  Super,
              ],
              key: "bracketleft",
          ): Focus(Left),
          (
              modifiers: [
                  Super,
              ],
              key: "Left",
          ): Move(Left),
          (
              modifiers: [
                  Super,
              ],
              key: "l",
          ): System(LockScreen),
          (
              modifiers: [],
              key: "Print",
          ): Disable,
          (
              modifiers: [
                  Super,
              ],
              key: "Right",
          ): Move(Right),
          (
              modifiers: [
                  Super,
                  Ctrl,
              ],
              key: "s",
              description: Some("1password"),
          ): Spawn("1password --quick-access"),
      }
    '';
  };
}
