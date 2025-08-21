{ config, pkgs, lib, home-manager, omarchy, myFlakes, ... }:

let
  system = pkgs.system;
in {
  imports = [
    omarchy.nixosModules.default
  ];

  # Omarchy-nix uses greetd
  services.greetd.enable = lib.mkForce false;
  services.displayManager.defaultSession = "hyprland";
  programs.hyprland.withUWSM = true;

  programs._1password-gui.polkitPolicyOwners = lib.mkForce ["heywoodlh"];

  # https://github.com/henrysipp/omarchy-nix/blob/main/config.nix
  omarchy = {
    full_name = "Spencer Heywood";
    email_address = "github@heywoodlh.io";
    theme = "nord";
    theme_overrides = {
      wallpaper_path = ../../../assets/nord-nix.png;
    };
    quick_app_bindings = [
      "SUPER, return, exec, ${pkgs.gnome-terminal}/bin/gnome-terminal"
    ];
    exclude_packages = with pkgs; [
      chromium
      github-desktop
      lazydocker
      lazygit
      obsidian
      signal-desktop
    ];
  };

  home-manager = {
    users.heywoodlh = let
      homeDir = "/home/heywoodlh";
      screenshot = pkgs.writeShellScriptBin "screenshot.sh" ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -d)" - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';
      battpop = pkgs.writeShellScriptBin "battpop.sh" ''
        ${pkgs.libnotify}/bin/notify-send $(${pkgs.acpi}/bin/acpi -b | grep -Eo [0-9]+% | ${pkgs.coreutils}/bin/head -1)
      '';
      screenrecord = pkgs.writeShellScriptBin "screenrecord.sh" ''
        mkdir -p ${homeDir}/Videos
        filename="${homeDir}/Videos/$(date +%Y-%m-%d_%H-%M-%S).mp4"
        ${pkgs.wf-recorder}/bin/wf-recorder -g "$(${pkgs.slurp}/bin/slurp)" -t -f $filename
        [[ -e $filename ]] && ${pkgs.libnotify}/bin/notify-send "Screenrecord" "Saved to $filename"
      '';
      screenrecord-kill = pkgs.writeShellScriptBin "screenrecord-kill.sh" ''
        killall -SIGINT wf-recorder
      '';
    in {
      imports = [ omarchy.homeManagerModules.default ];
      programs.ghostty.enable = lib.mkForce false;
      programs.git.enable = lib.mkForce false;
      programs.neovim.enable = lib.mkForce false;
      dconf.settings."org/gnome/desktop/interface".gtk-theme = lib.mkForce "Adwaita";

      # Screen record desktop file
      home.file.".local/share/applications/screenrecord.desktop" = {
        enable = true;
        text = ''
          [Desktop Entry]
          Name=Screenrecord
          GenericName=recorder
          Comment=Interactively record screen
          Exec=${screenrecord}/bin/screenrecord.sh
          Terminal=false
          Type=Application
          Keywords=recorder;screen;record;video;hyprland
          Icon=nix-snowflake
          Categories=Utility;
        '';
      };
      # Screen record killer desktop file
      home.file.".local/share/applications/screenrecord-kill.desktop" = {
        enable = true;
        text = ''
          [Desktop Entry]
          Name=Screenrecord (Kill)
          GenericName=recorder-kill
          Comment=Kill recording screen
          Exec=${screenrecord-kill}/bin/screenrecord-kill.sh
          Terminal=false
          Type=Application
          Keywords=recorder;screen;record;video;hyprland
          Icon=nix-snowflake
          Categories=Utility;
        '';
      };


      wayland.windowManager.hyprland.extraConfig = ''
        env = NIXOS_OZONE_WL, 1
        # Guake-like terminal on Hyprland
        workspace = special:terminal, on-created-empty:${pkgs.gnome-terminal}/bin/gnome-terminal
        # Remap Caps Lock as Super key
        input {
          kb_options = caps:super
        }

        # Login apps
        exec-once = ${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland
        exec-once = ${pkgs._1password-gui}/bin/1password --silent
        exec-once = ${pkgs.kdePackages.polkit-kde-agent-1}/bin/polkit-kde-authentication-agent-1

        # My keybindings
        bind = CTRL, grave, togglespecialworkspace, terminal
        bind = SUPER, bracketleft, workspace, r-1
        bind = SUPER, bracketright, workspace, r+1
        bind = SUPER_SHIFT, s, exec, ${screenshot}/bin/screenshot.sh
        bind = CTRL_SHIFT, b, exec, ${battpop}/bin/battpop.sh
        bind = CTRL_SHIFT, e, exec, hyprctl dispatch exit
      '';
    };
  };
}
