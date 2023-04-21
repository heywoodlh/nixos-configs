{ config, pkgs, ... }:

{
  users.users.heywoodlh.extraGroups = [
    "libvirtd"
  ];
  environment.systemPackages = with pkgs; [
    libvirt
    packagekit
  ];

  services.cockpit = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf = {
      enable = true;
      packages = [ pkgs.OVMFFull.fd ];
    };
    qemu.swtpm.enable = true;
  };

  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
