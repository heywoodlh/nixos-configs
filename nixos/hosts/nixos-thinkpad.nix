{lib, ...}: {
  imports = [/etc/nixos/hardware-configuration.nix];

  security.pam.services.sudo.fprintAuth = true;
  services.fprintd.enable = true;
  services.fprintd.lid.authSkipLidClose = true;

  home-manager.users.heywoodlh.imports = [../../home/roles/kiwix.nix];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
