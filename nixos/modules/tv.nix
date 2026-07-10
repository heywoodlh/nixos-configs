{ config, pkgs, lib, nur, dark-wallpaper, light-wallpaper, ... }:
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
    environment.systemPackages = with pkgs; [
      libcec
    ];
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
    services.fwupd.enable = lib.mkForce false;
    powerManagement = {
      enable = true;
      resumeCommands = "${pkgs.bluez}/bin/bluetoothctl power on";
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

    # We don't need Steam Deck tweaks
    jovian.devices.steamdeck.enable = lib.mkForce false;

    systemd.user.services.cec-volume-sync = {
      description = "Sync PipeWire volume to TV via CEC";
      after = [ "pipewire-pulse.service" "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "cec-volume-sync" ''
          get_volume() {
            ${pkgs.pulseaudio}/bin/pactl get-sink-volume @DEFAULT_SINK@ \
              | grep -o '[0-9]*%' | head -1 | tr -d '%'
          }

          send_cec() {
            local cmd=$1 count=$2 i=0
            {
              while [ "$i" -lt "$count" ]; do
                printf '%s\n' "$cmd"
                i=$((i + 1))
              done
              printf 'q\n'
            } | ${pkgs.libcec}/bin/cec-client -d 1
          }

          prev_vol=$(get_volume)

          ${pkgs.pulseaudio}/bin/pactl subscribe 2>/dev/null | while IFS= read -r line; do
            case "$line" in
              *"'change' on sink"*)
                curr_vol=$(get_volume)
                if [ -n "$curr_vol" ] && [ "$curr_vol" != "$prev_vol" ]; then
                  delta=$((curr_vol - prev_vol))
                  if [ "$delta" -gt 0 ]; then
                    send_cec volup "$delta"
                  elif [ "$delta" -lt 0 ]; then
                    send_cec voldown "$((0 - delta))"
                  fi
                  prev_vol=$curr_vol
                fi
                ;;
            esac
          done
        '';
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

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
      };
    };
  };
}
