{ pkgs, config, lib, plasma-manager, nixpkgs-next, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  nixpkgs-stable = nixpkgs-next; # TODO: remove when nixpkgs-stable input is updated
  pkgs-nvidia = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  wake = pkgs.writeShellScriptBin "wake.sh" ''
    export QT_QPA_PLATFORM=xcb
    ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor --dpms on
    sleep 3
    sudo pkill -9 sunshine
  '';
in {
  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  # Use autologin X11 Plasma 5 over GNOME
  services.displayManager.ly.enable = lib.mkForce false;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.desktopManager.plasma6.enable = true;
  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  environment.systemPackages = [
    wake
  ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "heywoodlh";
  };

  services.sunshine = {
    enable = true;
    package = pkgs-nvidia.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs-nvidia.cudaPackages;
    };

    settings = {
      resolutions = "[ 1920x1080 ]";
      system_tray = false;
      fps = "[ 60 120 ]";
      av1_mode = 1;
      global_prep_cmd = let
        autoAdjustRes = pkgs.writeShellScript "res.sh" ''
          ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.HDMI-A-1.mode.''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS} | grep -q 'not found'
          if [[ "$?" == 0 ]]
          then
             msg="$(date) unable to automatically adjust resolution, falling back to 1080 -- requested resolution: ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}"
             echo "$msg" | tee -a /tmp/sunshine-res.log
             ${pkgs.libnotify}/bin/notify-send "Unable to automatically adjust resolution, see /tmp/sunshine-res.log"
             ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.HDMI-A-1.mode.1920x1080@60 || true
          else
             echo "$(date) successfully adjusted resolution: ''${SUNSHINE_CLIENT_WIDTH}x''${SUNSHINE_CLIENT_HEIGHT}@''${SUNSHINE_CLIENT_FPS}" | tee -a /tmp/sunshine-res.log
          fi
          '';
      in builtins.toJSON [
        {
          do = "${autoAdjustRes}";
          undo = "";
        }
      ];
    };

    applications = let
      wake = pkgs.writeShellScript "wake.sh" ''
        ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor --dpms on
      '';
    in {
      apps = [
        {
          name = "Desktop";
          detached = [ "${wake}" ];
          image-path = "desktop.png";
        }
      ] ++ lib.optionals (config.programs.steam.enable) [
        {
          name = "Steam Big Picture";
          detached = [ "${wake}; sudo -u heywoodlh ${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture" ];
          output = "/tmp/steam.txt";
          prep-cmd = {
            do = "";
            undo = [ "sudo -u heywoodlh ${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://close/bigpicture" ];
          };
          image-path = "steam.png";
        }
      ];
    };

    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  home-manager = {
    users.heywoodlh = { ... }: {
      imports = [
        (plasma-manager + /modules/default.nix)
      ];
      programs.ashell.enable = lib.mkForce false;
      # Ensure to disable screen dim on Nvidia systems: https://bugs.kde.org/show_bug.cgi?id=460341
      programs.plasma = {
        enable = true;
        kscreenlocker.autoLock = false;
        desktop.icons.size = 1;
        session = {
          sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
          general.askForConfirmationOnLogout = false;
        };
        powerdevil.AC = {
          powerProfile = "performance";
          autoSuspend.action = "nothing";
          whenSleepingEnter = "hybridSleep";
        };
      };
      home.packages = with pkgs; [
        steamtinkerlaunch
        sunshine
        wget # winetricks requires GNU wget
        wineWowPackages.stable # support both 32-bit and 64-bit applications
        winetricks
      ];
      #heywoodlh.home.autostart = [
      #  {
      #    name = "Steam";
      #    command = ''
      #      sleep 30 # start last
      #      ${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture
      #    '';
      #  }
      #];
    };
  };
}
