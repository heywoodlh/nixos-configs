{ config, pkgs, lib, nur, dark-wallpaper, light-wallpaper, youtube-htpc, ... }:
with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.tv;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.heywoodlh.nixos.tv = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh TV configuration.
      '';
      type = bool;
    };
    user = mkOption {
      default = "heywoodlh";
      description = ''
        User for heywoodlh configuration.
      '';
      type = str;
    };
    remote = mkOption {
      default = true;
      description = ''
        Enable Makima configuration for Air Mouse Remote MX3 Pro.
      '';
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    powerManagement = {
      enable = true;
      resumeCommands = ''
        ${pkgs.bluez}/bin/bluetoothctl power on
      '';
    };
    hardware.bluetooth.powerOnBoot = true;
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", ATTR{power/wakeup}="enabled"
    '';
    services.logind.settings.Login = {
      IdleAction = "suspend";
      IdleActionSec = "15min";
    };

    heywoodlh = {
      defaults = {
        audio = true;
        bluetooth = true;
        quietBoot = true;
      };
      nixos = {
        steam-deck.enable = true;
        cachyos-kernel.enable = true;
      };
    };

    environment.systemPackages = let
      # produces `htpc-yt`
      youtube-htpc-bin = pkgs.writeShellScriptBin "youtube-htpc" ''
        export DISPLAY=:0
        export XDG_RUNTIME_DIR=/run/user/$(id -u)
        ${youtube-htpc.packages.${system}.default}/bin/htpc-yt --ozone-platform=x11 --no-sandbox --password-store=basic $@ &>/tmp/youtube.log
      '';
    in [
      youtube-htpc-bin
    ];

    # Jovian-NixOS tweaks
    jovian.devices.steamdeck.enable = lib.mkForce false;
    services.fwupd.enable = lib.mkForce false;

    # Makima needs access to /dev/input/event* to remap devices
    users.users.${cfg.user}.extraGroups = [ "input" ];

    # Home-manager configs
    home-manager = {
      extraSpecialArgs = {
        inherit nur;
        inherit light-wallpaper;
        inherit dark-wallpaper;
      };
      users.${cfg.user} = { ... }: {
        imports = [
          ../../home/desktop.nix # base desktop.nix
          ../../home/linux/desktop.nix # linux-specific desktop.nix
        ];
        heywoodlh.home.onepassword.enable = true;
        heywoodlh.home.llm = {
          enable = true;
          homelab = true;
          lmstudio.enable = false;
        };
        home.packages = let
          plex-htpc = pkgs.writeShellScriptBin "plex-htpc" ''
            QT_STYLE_OVERRIDE="" ${pkgs.flatpak}/bin/flatpak run --user tv.plex.PlexHTPC
          '';
        in [
          plex-htpc
        ];
        home.activation.install-plex-htpc = ''
          ${pkgs.flatpak}/bin/flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo &>/dev/null
          ${pkgs.flatpak}/bin/flatpak install -y --noninteractive --user flathub tv.plex.PlexHTPC
        '';

        # Makima to remap remote control buttons to useful binds
        systemd.user.services.makima = optionalAttrs (cfg.remote) {
          Unit.Description = "Makima remapping daemon";
          Install.WantedBy = [ "gamescope-session.service" ];
          Service = {
            EnvironmentFile = "%t/gamescope-environment";
            ExecStart = "${pkgs.makima}/bin/makima daemon start";
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        # Quality of life fixes for the AirMouse remote
        home.file = {
          ".config/makima/XING WEI 2.4G USB USB Composite Device Consumer Control.toml" = {
            enable = cfg.remote;
            text = ''
              [remap]
              # Remap back button to escape
              KEY_BACK = [ "KEY_ESC" ]

              # Remap home button to SHIFT+TAB (main menu)
              KEY_HOMEPAGE = [ "KEY_LEFTSHIFT", "KEY_TAB" ]
            '';
          };
          ".config/makima/XING WEI 2.4G USB USB Composite Device.toml" = {
            enable = cfg.remote;
            text = ''
              [remap]
              # Remap menu button to CTRL+2 (quick access menu)
              KEY_COMPOSE = [ "KEY_LEFTCTRL", "KEY_2" ]
            '';
          };
        };
      };
    };
  };
}
