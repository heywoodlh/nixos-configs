{ config, pkgs, lib, ... }:

{
  programs.steam.enable = true;

  # Add KDE for gaming
  services.desktopManager.plasma6.enable = true;
  programs.kdeconnect.package = lib.mkForce pkgs.gnomeExtensions.gsconnect;
  programs.ssh.askPassword = lib.mkForce "${pkgs.seahorse}/libexec/seahorse/ssh-askpass";

  hardware.bluetooth.input = {
    General = {
      UserspaceHID = true;
      ClassicBondedOnly = false;
      LEAutoSecurity = false;
    };
  };
  boot.kernelModules = [
    "hid_microsoft" # Xbox One Elite 2 controller driver preferred by Steam
    "uinput"
  ];
  # https://github.com/ValveSoftware/steam-for-linux/issues/9310#issuecomment-2166248312
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "xbox-one-elite-2-udev-rules";
      text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
      destination = "/etc/udev/rules.d/60-xbox-elite-2-hid.rules";
    })
  ];
}

