{ config, pkgs, ... }:

{
  users.users.heywoodlh.extraGroups = [
    "libvirtd"
  ];
  environment.systemPackages = with pkgs; [
    libvirt
  ];

  services.cockpit = {
    enable = true;
    openFirewall = true;
  };

  services.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.swtpm.enable = true;
  };

  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
