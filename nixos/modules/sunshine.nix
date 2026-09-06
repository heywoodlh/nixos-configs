{ pkgs, nixpkgs-sunshine, config, lib, plasma-manager, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.sunshine;
  system = pkgs.stdenv.hostPlatform.system;
  sunshine-pkgs = import nixpkgs-sunshine {
    inherit system;
    config = {
      allowUnfree = true;
    };
  };
in {
  options.heywoodlh.nixos.sunshine = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh sunshine configuration.
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
    extraConfig = mkOption {
      default = {};
      description = ''
        Extra settings for Sunshine to be placed in `services.sunshine.settings`.
      '';
      type = attrs;
    };
    resolutions = mkOption {
      default = "[ 1920x1080 ]";
      description = ''
        Allowed resolutions.
      '';
      type = str;
    };
    dynamic = mkOption {
      default = false;
      description = ''
        Automatically adjust resolution based on the connecting client's resolution.
      '';
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    heywoodlh.nixos.kde.enable = true;

    # Add input rules comparable to Steam for Sunshine to work with/without Steam
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "sunshine-uinput-uaccess";
        text = ''KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"'';
        destination = "/etc/udev/rules.d/60-sunshine-uinput.rules";
      })
    ];

    # Use KDE autologin
    services.displayManager = {
      gdm.enable = lib.mkForce false;
      defaultSession = lib.mkForce "plasma";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    services.displayManager.autoLogin = {
      enable = true;
      user = cfg.user;
    };

    # https://github.com/orgs/LizardByte/discussions/439#discussioncomment-15813284
    security.wrappers.conntrack = lib.mkIf config.services.sunshine.enable {
      source = "${pkgs.conntrack-tools}/bin/conntrack";
      # conntrack needs cap_net_admin to run as a normal user
      capabilities = "cap_net_admin+ep";
      owner = "root"; group = "root";
    };
    systemd.user.services.sunshine-wake-monitor= lib.mkIf config.services.sunshine.enable {
      description = "Monitor Sunshine TCP connections and wake monitors";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "sunshine_wake_monitor" ''
          ${config.security.wrapperDir}/conntrack -E -e new -p tcp --dport ${toString (config.services.sunshine.settings.port - 5)} | \
          while read line; do
            echo "New Sunshine connection detected, waking up the monitors"
            ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor -d on
            sleep 5
          done
        '';
        Restart = "on-failure";
      };
    };

    services.sunshine = {
      enable = true;
      package = sunshine-pkgs.sunshine.override {
        cudaSupport = true;
        cudaPackages = pkgs.cudaPackages;
        libva = pkgs.libva;
      };

      settings = cfg.extraConfig // {
        resolutions = cfg.resolutions;
        system_tray = false;
        fps = "[ 60 ]";
        av1_mode = 1;
        back_button_timeout = 2000;
        origin_web_ui_allowed = "wan";
      } // lib.optionalAttrs cfg.dynamic {
        global_prep_cmd = let
          autoAdjustRes = pkgs.writeShellScript "res.sh" ''
            output="HDMI-A-1"
            width="''${SUNSHINE_CLIENT_WIDTH}"
            height="''${SUNSHINE_CLIENT_HEIGHT}"
            fps="''${SUNSHINE_CLIENT_FPS}"

            # Dummy HDMI adapters only advertise a fixed EDID mode list, so a
            # resolution outside that set (e.g. a tablet's native panel res)
            # has to be injected as a custom mode before kscreen-doctor can
            # switch to it. Check for an existing mode of this size first so
            # repeated connects don't pile up duplicate custom modes.
            have_mode="$(${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor -j | ${pkgs.jq}/bin/jq -r --arg o "$output" --argjson w "$width" --argjson h "$height" '.outputs[] | select(.name == $o) | .modes[] | select(.size.width == $w and .size.height == $h) | .id' | head -n1)"
            if [[ -z "$have_mode" ]]
            then
              ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor "output.$output.addCustomMode.$width.$height.$((''${fps%%.*} * 1000)).reduced"
            fi

            ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor "output.$output.mode.''${width}x''${height}@''${fps}" | grep -q 'not found'
            if [[ "$?" == 0 ]]
            then
               msg="$(date) unable to automatically adjust resolution, falling back to 1080 -- requested resolution: ''${width}x''${height}@''${fps}"
               echo "$msg" | tee -a /tmp/sunshine-res.log
               ${pkgs.libnotify}/bin/notify-send "Unable to automatically adjust resolution, see /tmp/sunshine-res.log"
               ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor "output.$output.mode.1920x1080@60" || true
            else
               echo "$(date) successfully adjusted resolution: ''${width}x''${height}@''${fps}" | tee -a /tmp/sunshine-res.log
            fi
            '';
        in builtins.toJSON [
          {
            do = "${autoAdjustRes}";
            undo = "";
          }
        ];
      };

      applications = {
        apps = [
          {
            name = "Desktop";
            prep-cmd = {
              do = "QT_QPA_PLATFORM=wayland DISPLAY=:0 ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor --dpms on";
              undo = [ "" ];
            };
            image-path = "desktop.png";
          }
        ] ++ lib.optionals (config.programs.steam.enable) [
          {
            name = "Steam Big Picture";
            detached = [ "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture" ];
            output = "/tmp/steam.txt";
            prep-cmd = {
              do = "QT_QPA_PLATFORM=wayland DISPLAY=:0 ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor --dpms on";
              undo = [ "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture" ];
            };
            image-path = "steam.png";
          }
        ];
      };
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };

    security.wrappers.sunshine.capabilities = lib.mkForce "cap_sys_admin+p cap_sys_nice+p";

    home-manager = {
      users."${cfg.user}" = { ... }: {
        imports = [
          (plasma-manager + /modules/default.nix)
        ];
        programs.ashell.enable = lib.mkForce false;
        programs.plasma = {
          kscreenlocker.autoLock = false;
        };
        home.file.".config/fish/config.fish".text = ''
          export XDG_RUNTIME_DIR="/run/user/$(id -u)"
          export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        '';
        home.packages = with pkgs; [
          sunshine
        ] ++ lib.optionals (config.programs.steam.enable) [
          steamtinkerlaunch
          wget # winetricks requires GNU wget
          wineWow64Packages.stable # support both 32-bit and 64-bit applications
          winetricks
        ];

        home.activation.fix-sunshine-service = ''
          # services.sunshine installs its unit to /etc/systemd/user (system-wide, not
          # per-user), so restart it here on every activation -- otherwise a rebuild that
          # changes the sunshine package/config just rewrites the unit file on disk while
          # the already-running service keeps serving the stale one.
          if [ -e "/etc/systemd/user/sunshine.service" ]
          then
            ${pkgs.systemd}/bin/systemctl --user daemon-reload || true
            ${pkgs.systemd}/bin/systemctl --user restart sunshine.service || true
          fi
        '';
      };
    };
  };
}
