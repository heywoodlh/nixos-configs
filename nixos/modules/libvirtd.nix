{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.nixos.libvirtd;
in {
  options.heywoodlh.nixos.libvirtd = {
    enable = mkOption {
      default = true;
      description = "Enable libvirt virtualization.";
      type = bool;
    };
    username = mkOption {
      default = config.heywoodlh.defaults.user.name;
      description = "Non-root user that will run libvirt.";
      type = str;
    };
  };

  config = mkIf cfg.enable {
    users.users.${cfg.username}.extraGroups = [ "libvirtd" ];

    boot.kernelModules = lib.optionals (pkgs.stdenv.isx86_64) [
      "kvm-amd"
      "kvm-intel"
    ];

    environment.systemPackages = with pkgs; [
      dnsmasq
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true; # TPM
          vhostUserPackages = [ pkgs.virtiofsd ];
        };
      };
      spiceUSBRedirection.enable = true;
    };

    system.activationScripts.default-virsh-net = ''
      ${pkgs.libvirt}/bin/virsh net-info default >/dev/null 2>&1
      if [ $? -ne 0 ]
      then
        ${pkgs.libvirt}/bin/virsh net-define ${pkgs.writeText "default-network.xml" ''
            <network>
              <name>default</name>
              <forward mode='nat'/>
              <bridge name='virbr0' stp='on' delay='0'/>
              <ip address='192.168.122.1' netmask='255.255.255.0'>
                <dhcp>
                  <range start='192.168.122.2' end='192.168.122.254'/>
                </dhcp>
              </ip>
            </network>
          ''} &>/dev/null || true
      fi
      ${pkgs.libvirt}/bin/virsh net-start default &>/dev/null || true
      ${pkgs.libvirt}/bin/virsh net-autostart default &>/dev/null || true
    '';
  };
}
