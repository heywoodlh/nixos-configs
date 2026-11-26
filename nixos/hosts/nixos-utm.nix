{nixpkgs, ...}: {
  imports = [
    /etc/nixos/hardware-configuration.nix
    (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
  ];

  services.qemuGuest.enable = true;
}
