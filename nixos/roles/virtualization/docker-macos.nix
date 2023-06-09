{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      docker-macos = {
        image = "docker.io/sickcodes/docker-osx:naked-auto";
        autoStart = true;
        ports = [
          "5900:5900"
        ];
        volumes = [
          "/media/virtual-machines-2/docker-macos/output.env:/env"
          "/media/virtual-machines-2/docker-macos/image/mac_hdd_ng_auto_monterey.img:/image"
        ];
        environmentFiles = [
          /media/virtual-machines-2/docker-macos/environment
        ];
        environment = {
          GENERATE_UNIQUE = "true";
          GENERATE_SPECIFIC = "true";
          DEVICE_MODEL = "iMacPro1,1";
          MASTER_PLIST_URL = "https://raw.githubusercontent.com/sickcodes/osx-serial-generator/master/config-custom.plist";
          SCREEN_SHARE_PORT = "5900";
        };
        extraOptions = [
          "--device=/dev/kvm"
        ];
      };
    };
  };
}
