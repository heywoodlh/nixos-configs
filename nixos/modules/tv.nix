{ config, pkgs, lib, ... }:
with lib;

let
  cfg = config.heywoodlh.nixos.tv;

in {
  options.heywoodlh.nixos.tv = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh TV configuration.
      '';
      type = types.bool;
    };
    user = mkOption {
      default = "heywoodlh";
      description = ''
        User for heywoodlh configuration.
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # Fix bluetooth continuously resetting on Intel Mac Mini
    boot.extraModprobeConfig = ''
      options btusb enable_autosuspend=0
    '';

    services.pipewire.wireplumber.extraConfig."51-hdmi-default" = {
      "monitor.alsa.rules" = [
        {
          matches = [ { "node.name" = "~alsa_output.*hdmi.*"; } ];
          actions.update-props."priority.session" = 2000;
        }
      ];
    };

    services.logind.settings.Login = {
      HandlePowerKey = "hibernate";
    };

    heywoodlh = {
      stylix.enable = true;
      hyprland = lib.mkForce false;
      nixos = {
        kde.enable = true;
        gaming = {
          enable = true;
          console = true;
        };
      };
      defaults = {
        bluetooth = true;
        audio = true;
        keyring = true;
        quietBoot = true;
      };
      sshd.enable = true;
    };


    # Use KDE autologin
    services.displayManager = {
      gdm.enable = lib.mkForce false;
      defaultSession = lib.mkForce "plasma";
      sddm = {
        enable = true;
        wayland.enable = lib.mkForce false;
      };
    };
    services.displayManager.autoLogin = {
      enable = true;
      user = cfg.user;
    };

    boot.plymouth.enable = true;

    environment.systemPackages = with pkgs; [
      flex-launcher
      plex-htpc
      moonlight-qt
    ];

    # Gamepad support in userland
    services.udev = {
      packages = with pkgs; [
        game-devices-udev-rules
      ];
    };
    environment.sessionVariables = {
      SDL_GAMECONTROLLERCONFIG =
        pkgs.fetchFromGitHub {
          owner = "mdqinc";
          repo = "SDL_GameControllerDB";
          rev = "992a0caf690e32a332a9707c355a4444516a2764";
          sha256 = "sha256-hv1xtAXpSQlzO1nSUkFaeoth4o0V7aUjzZgqnehezaY=";
        }
        + "/gamecontrollerdb.txt";
    };


    home-manager.users.${cfg.user} = {
      heywoodlh.home = {
        hyprland = lib.mkForce false;
        llm.homelab = lib.mkForce true;
        #autostart = [
        #  {
        #    name = "flex-launcher";
        #    command = "${pkgs.flex-launcher}/bin/flex-launcher";
        #  }
        #];
      };

      home.file.".config/flex-launcher/config.ini".text = ''
        [General]
        DefaultMenu=Main
        VSync=true
        #FPSLimit=
        #ApplicationTimeout=15
        OnLaunch=None
        WrapEntries=false
        ResetOnBack=false
        MouseSelect=true
        InhibitOSScreensaver=false
        #StartupCmd=
        #QuitCmd=

        [Background]
        #Mode=Image
        #Color=#000000
        #Image=/example.png
        #SlideshowDirectory=
        #SlideshowImageDuration=30
        #SlideshowTransitionTime=3
        #ChromaKeyColor=#010101
        Overlay=false
        OverlayColor=#000000
        OverlayOpacity=50%

        [Layout]
        MaxButtons=8
        IconSize=256
        IconSpacing=15%
        VCenter=50%

        [Titles]
        Enabled=true
        Font=${pkgs.flex-launcher}/share/flex-launcher/assets/fonts/OpenSans-Regular.ttf
        FontSize=36
        Color=#FFFFFF
        Opacity=90%
        Shadows=true
        ShadowColor=#8aadf4
        OversizeMode=Shrink
        Padding=20

        [Highlight]
        Enabled=true
        FillColor=#FFFFFF
        FillOpacity=25%
        OutlineSize=0
        OutlineColor=#0000FF
        OutlineOpacity=100%
        CornerRadius=30
        VPadding=30
        HPadding=30

        [Scroll Indicators]
        Enabled=true
        FillColor=#FFFFFF
        OutlineSize=0
        OutlineColor=#000000
        Opacity=100%

        [Clock]
        Enabled=true
        ShowDate=true
        Alignment=Right
        Font=${pkgs.flex-launcher}/share/flex-launcher/assets/fonts/SourceSansPro-Regular.ttf
        FontSize=50
        FontColor=#FFFFFF
        Shadows=false
        ShadowColor=#000000
        Margin=5%
        Opacity=100%
        TimeFormat=Auto
        DateFormat=Auto
        IncludeWeekday=true

        [Screensaver]
        Enabled=false
        IdleTime=300
        Intensity=70%
        PauseSlideshow=true

        [Hotkeys]
        # Esc to quit
        Hotkey1=#1B;:quit

        [Gamepad]
        Enabled=true
        DeviceIndex=-1
        #ControllerMappingsFile=
        LStickX-=:left
        LStickX+=:right
        #LStickY-=
        #LStickY+=
        #RStickX-=
        #RStickX+=
        #RStickY-=
        #RStickY+=
        #LTrigger=
        #RTrigger=
        ButtonA=:select
        ButtonB=:back
        #ButtonX=
        #ButtonY=
        #ButtonBack=
        #ButtonGuide=
        #ButtonStart=
        #ButtonLeftStick=
        #ButtonRightStick=
        #ButtonLeftShoulder=
        #ButtonRightShoulder=
        #ButtonDPadUp=
        #ButtonDPadDown=
        ButtonDPadLeft=:left
        ButtonDPadRight=:right

        # Menu configurations
        [Main]
        Entry1=Plex;${pkgs.flex-launcher}/share/flex-launcher/assets/icons/plex.png;DISABLE_WAYLAND=1 plex-htpc
        Entry2=Moonlight;${pkgs.moonlight-qt}/share/icons/hicolor/scalable/apps/moonlight.svg;moonlight

        [System]
        Entry1=Exit;${pkgs.flex-launcher}/share/flex-launcher/assets/exit.png;:quit
        Entry2=Shutdown;${pkgs.flex-launcher}/share/flex-launcher/assets/icons/system.png;:shutdown
        Entry3=Restart;${pkgs.flex-launcher}/share/flex-launcher/assets/icons/restart.png;:restart
        Entry4=Sleep;${pkgs.flex-launcher}/share/flex-launcher/assets/icons/sleep.png;:sleep
      '';
      home.file.".config/fish/config.fish".text = ''
        export XDG_RUNTIME_DIR="/run/user/$(id -u)"
        export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
      '';
    };
  };
}
