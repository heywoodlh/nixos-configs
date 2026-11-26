{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.types; let
  cfg = config.heywoodlh.nixos.sunshine;
  niri = pkgs.writeShellScriptBin "niri-session" ''
    : "''${XDG_RUNTIME_DIR:=/run/user/$(${pkgs.coreutils}/bin/id -u)}"
    if [ -z "$WAYLAND_DISPLAY" ]
    then
      socket=$(${pkgs.coreutils}/bin/ls -1 "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)
      [ -n "$socket" ] && export WAYLAND_DISPLAY="''${socket##*/}"
    fi
    exec ${pkgs.niri}/bin/niri msg "$@"
  '';
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

    heywoodlh.niri.enable = true;

    # Add input rules comparable to Steam for Sunshine to work with/without Steam
    services.udev.packages = [
      (pkgs.writeTextFile {
        name = "sunshine-uinput-uaccess";
        text = ''KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput"'';
        destination = "/etc/udev/rules.d/60-sunshine-uinput.rules";
      })
    ];

    services.displayManager.autoLogin = {
      enable = true;
      user = cfg.user;
    };

    # https://github.com/orgs/LizardByte/discussions/439#discussioncomment-15813284
    security.wrappers.conntrack = lib.mkIf config.services.sunshine.enable {
      source = "${pkgs.conntrack-tools}/bin/conntrack";
      # conntrack needs cap_net_admin to run as a normal user
      capabilities = "cap_net_admin+ep";
      owner = "root";
      group = "root";
    };
    systemd.user.services.sunshine-wake-monitor = lib.mkIf config.services.sunshine.enable {
      description = "Monitor Sunshine TCP connections and wake monitors";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "sunshine_wake_monitor" ''
          ${config.security.wrapperDir}/conntrack -E -e new -p tcp --dport ${toString (config.services.sunshine.settings.port - 5)} | \
          while read line; do
            echo "New Sunshine connection detected, waking up the monitors"
            ${niri}/bin/niri-session action power-on-monitors
            sleep 5
          done
        '';
        Restart = "on-failure";
      };
    };

    services.sunshine = {
      enable = true;
      # cudaSupport wraps the binary, which breaks setcap; bake the RPATH instead.
      package =
        (pkgs.sunshine.override {
          cudaSupport = true;
          cudaPackages = pkgs.cudaPackages;
          libva = pkgs.libva;
        }).overrideAttrs (_: {
          postFixup = ''
            ${pkgs.patchelf}/bin/patchelf --set-rpath \
              "$(${pkgs.patchelf}/bin/patchelf --print-rpath $out/bin/sunshine):${pkgs.lib.makeLibraryPath [pkgs.vulkan-loader]}" \
              $out/bin/sunshine
          '';
        });

      settings =
        cfg.extraConfig
        // {
          system_tray = false;
          back_button_timeout = 2000;
          origin_web_ui_allowed = "wan";
        }
        // lib.optionalAttrs cfg.dynamic {
          global_prep_cmd = let
            autoAdjustRes = pkgs.writeShellScript "res.sh" ''
              output="HDMI-A-1"
              width="''${SUNSHINE_CLIENT_WIDTH}"
              height="''${SUNSHINE_CLIENT_HEIGHT}"
              fps="''${SUNSHINE_CLIENT_FPS}"

              if ! ${niri}/bin/niri-session output "$output" mode "''${width}x''${height}@''${fps}" >/tmp/sunshine-res.log 2>&1
              then
                 msg="$(date) unable to automatically adjust resolution, falling back to 1080 -- requested resolution: ''${width}x''${height}@''${fps}"
                 echo "$msg" | tee -a /tmp/sunshine-res.log
                 ${pkgs.libnotify}/bin/notify-send "Unable to automatically adjust resolution, see /tmp/sunshine-res.log"
                 ${niri}/bin/niri-session output "$output" mode "1920x1080@60" || true
              else
                 echo "$(date) successfully adjusted resolution: ''${width}x''${height}@''${fps}" | tee -a /tmp/sunshine-res.log
              fi
            '';
          in
            builtins.toJSON [
              {
                do = "${autoAdjustRes}";
                undo = "";
              }
            ];
        };

      applications = {
        apps =
          [
            {
              name = "Desktop";
              prep-cmd = {
                do = "${niri}/bin/niri-session action power-on-monitors";
                undo = [""];
              };
              image-path = "desktop.png";
            }
          ]
          ++ lib.optionals (config.programs.steam.enable) [
            {
              name = "Steam Big Picture";
              detached = ["${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture"];
              output = "/tmp/steam.txt";
              prep-cmd = {
                do = "${niri}/bin/niri-session action power-on-monitors";
                undo = ["${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture"];
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
      users."${cfg.user}" = {...}: {
        home.file.".config/fish/config.fish".text = ''
          export XDG_RUNTIME_DIR="/run/user/$(id -u)"
          export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
        '';
        home.packages = with pkgs;
          [
            sunshine
          ]
          ++ lib.optionals (config.programs.steam.enable) [
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
