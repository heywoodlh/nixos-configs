{ config, pkgs, cosmic-session, ...}:

let
  system = pkgs.system;
  cosmic = cosmic-session.packages.${system}.default;
in {
  environment.systemPackages = with pkgs; [
    cosmic-applibrary
    cosmic-applets
    cosmic-bg
    cosmic-comp
    cosmic-edit
    cosmic-files
    cosmic-greeter
    cosmic-icons
    cosmic-launcher
    cosmic-notifications
    cosmic-osd
    cosmic-panel
    cosmic-randr
    cosmic-screenshot
    cosmic-settings
    cosmic-settings-daemon
    cosmic-term
    cosmic-workspaces-epoch
  ];

  # COSMIC portal doesn't support everything yet
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-cosmic
  ];

  # session files for display manager and systemd
  services.xserver.displayManager.sessionPackages = [ cosmic ];
  systemd.packages = [ cosmic ];
}
