{lib, ...}: {
  imports = [/etc/nixos/hardware-configuration.nix];

  home-manager.users.heywoodlh.imports = [../../home/roles/kiwix.nix];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
