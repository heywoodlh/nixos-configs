{ config, pkgs, ... }:

{
  users.users.heywoodlh.extraGroups = [
    "libvirtd"
  ];
  environment.systemPackages = with pkgs; [
    libvirt
  ];

  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
