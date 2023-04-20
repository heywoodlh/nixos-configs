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

  boot.extraModprobeConfig = "options kvm_intel nested=1";
}
