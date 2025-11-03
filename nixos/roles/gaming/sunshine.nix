{ config, lib, pkgs, home-manager, plasma-manager, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
  # using pre-release for now
  # (this URL is updated daily, so will break)
  sunshineExe = pkgs.fetchurl {
    url = "https://github.com/LizardByte/Sunshine/releases/download/v2024.1219.161129/sunshine.AppImage";
    hash = "sha256-ygUnlahHEBnN2AHPmNTTtFjeZTvmvplr9P3r7tdJpok=";
  };
  # Using appimage over NixOS service
  # For some reason, NixOS+Sunshine won't properly figure out GPU configuration
  sunshine = pkgs.writeShellScriptBin "sunshine" ''
    ${pkgs.appimage-run}/bin/appimage-run ${sunshineExe} $@
  '';
in {
  imports = [
    ./proton-ge.nix
  ];
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };
  hardware.xone.enable = true; # support for the xbox controller USB dongle

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = false;
    "autovt@tty1".enable = false;
  };

  # Use autologin X11 Plasma 5 over GNOME
  services.xserver.displayManager.gdm.enable = lib.mkForce false;
  services.xserver.desktopManager.gnome.enable = lib.mkForce false;
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.xserver.desktopManager.plasma5.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "heywoodlh";
  };
  # Enable with: systemctl enable --user --now sunshine.service
  systemd.user.services.sunshine = {
    description = "Sunshine self-hosted game stream host for Moonlight";
    startLimitBurst = 5;
    after = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    startLimitIntervalSec = 500;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${sunshine}/bin/sunshine";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
  home-manager = {
    users.heywoodlh = { ... }: {
      imports = [
        (plasma-manager + /modules/default.nix)
        ../../../home/modules/default.nix
      ];
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
          dimDisplay.enable = false;
          autoSuspend.action = "nothing";
          turnOffDisplay.idleTimeout = "never";
          whenSleepingEnter = "hybridSleep";
        };
      };
      home.packages = with pkgs; [
        proton-caller
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
