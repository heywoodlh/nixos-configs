{ config, pkgs, ... }:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.ovmf.enable = true;
    qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    qemu.swtpm.enable = true;
  };
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gnome.gnome-boxes
    virt-manager
    win-virtio
  ];
  environment.sessionVariables.LIBVIRT_DEFAULT_URI = [ "qemu:///system" ];
  users.users.heywoodlh.extraGroups = [ "libvirtd" "kvm" "qemu-libvirtd" ];
}
