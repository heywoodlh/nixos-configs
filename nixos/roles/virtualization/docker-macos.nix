{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      docker-macos = {
        image = "docker.io/sickcodes/docker-osx:naked-auto";
        autoStart = true;
        ports = [
          "5999:5999"
        ];
        volumes = [
          "/media/virtual-machines-2/docker-macos/output.env:/env"
          "/media/virtual-machines-2/docker-macos/image/mac_hdd_ng.img:/image"
        ];
        environmentFiles = [
          /media/virtual-machines-2/docker-macos/environment
        ];
        environment = {
          GENERATE_UNIQUE = "true";
          GENERATE_SPECIFIC = "true";
          MASTER_PLIST_URL = "https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/config-custom.plist";
        };
        extraOptions = [
          "--device=/dev/kvm"
          "--privileged"
          "-e=EXTRA=-display none -vnc 0.0.0.0:99,password=on"
        ];
      };
    };
  };
}
