## NixOS configs specific to SteamDeck

{ config, pkgs, ... }:

let
  jovian-nixos-modules = import (builtins.fetchGit {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    ref = "development";
  }) {
    modules = "modules";
  };
in {
  imports = [ jovian-nixos-modules ];
  jovian.devices.steamdeck.enable = true;
  jovian.steam.enable = true;

  services.xserver.displayManager.defaultSession = "Gaming Mode";
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "heywoodlh";

  users.users.heywoodlh = {
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC1aOhZI4Uo8jpPnmJe2aalB/HT2n42bo270IVxyRLURrmNrro8y/MEDD55GU9AVieVu2P+W4xBlWYaDJjSngWAh+zV6hrEhCSeGXiRnIZ+dpOBU5gcOFJxOpvSVawmqJFTjFUAdkHSLYuf9dtbasDkbxyyb/8Hh9jFjT0bisSRKi/SEmkh5m4nU7ySa1ltb6htUgQ/Y71Fi09BJWhktiT9HrtL4Gs0wzch9biaH/AFGbRNEnAZgQMAL/zS08IfevR7sYoHyjwVSwWVmA4TOhsm+auu9zPV4WgrnY2BNy+H9tF74AP6s+sf19uQG/2qVS3xcrvw2VhQCwPGHpv0o0tGLaCQBwjmqhbrBzVO4Hy1d/vskxe7Zr6IEEbQTLXTsYo6/yiEXOTzOvN7/V/zzdZkeUdRFGxqIu3EABH5wxNYOMwXNlOjnsxsE5VTovkMeIb+No1itaj1xGXuKBKJzRzKJ9pPLxtiaOimXxG4LYg3Ef50V6JzwT7UxY4DiS3JBUxQSxQ5CxifKRN/pCzUMlsdm+yIoXhy57r6JjFtnzet2Ytz12Vp8vRx6ZNH7upMxMBxmWH0sG7hf7fLjmVuurcL7pIB5U7a5rwUhfTjLUAJSg+DDvaOHyhBUsZp7wRxwoJuctvfxoxSkQtNlimWOwuPQgmNIfjjPQUKwM3j95RZiw== tyranny" "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPjnAIPI3ypyi8qn8QNlh8jlVxtaZYKRxXjJ1CDWj+Luuv3cbdsmM8V2SeRToeJHCV/qROa8nEnrnFrUqQ3+9qE= chg-mac@secretive.C02GC0NYMD6R.local" ];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 51820 ];
    # For Mosh
    allowedUDPPortRanges = [
      { from = 60000; to = 61000; }
    ];
  };

  services.openssh.enable = true;
  services.openssh.sftpServerExecutable = "internal-sftp";

  system.stateVersion = "22.11";
}
