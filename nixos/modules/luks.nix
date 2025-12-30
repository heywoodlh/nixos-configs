{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.luksYubikey;
in {
  options.heywoodlh.luksYubikey = {
    enable = mkOption {
      default = false;
      description = ''
        Enable Yubikey luks single factor decryption.
        See the following gist for setup example:
        https://gist.github.com/heywoodlh/4cc0254359b173ba9f9a1ea8f3b2e49f
      '';
      type = bool;
    };
    device = mkOption {
      default = "";
      description = ''
        Full path of FAT boot device (i.e. /dev/nvme0n1p1).
      '';
      type = str;
    };
    name = mkOption {
      default = "luks";
      description = ''
        LUKS device name.
      '';
      type = str;
    };
    uuid = mkOption {
      default = "";
      description = ''
        LUKS device UUID.
      '';
      type = str;
    };
  };

  config = mkIf cfg.enable {
    boot.initrd = {
      availableKernelModules = [
        "vfat"
        "nls_cp437"
        "nls_iso8859-1"
      ];
      luks = {
        yubikeySupport = true;
        devices."${cfg.name}" = {
          fallbackToPassword = true;
          device = "/dev/disk/by-uuid/${cfg.uuid}";
          yubikey = {
            slot = 2;
            twoFactor = false;
            gracePeriod = 5;
            keyLength = 64;
            saltLength = 16;
            storage = {
              device = "${cfg.device}";
              fsType = "vfat";
              path = "/crypt-storage/default";
            };
          };
        };
      };
    };
  };
}
