{...}: {
  imports = [./nixos-build-hardware.nix];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  networking.hostName = "nixos-server";

  time.timeZone = "America/Denver";
}
