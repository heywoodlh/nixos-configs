{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.luks;
in {
  options.heywoodlh.luks = {
    enable = mkOption {
      default = false;
      description = ''
        Enable Yubikey luks single factor decryption.
        See the following gist for setup example:
        https://gist.github.com/heywoodlh/4cc0254359b173ba9f9a1ea8f3b2e49f
      '';
      type = bool;
    };
    boot = mkOption {
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
        LUKS block device UUID.
        Obtain with `sudo blkid`.
      '';
      type = str;
    };
    yubikey = mkOption {
      default = false;
      description = ''
        Enable Yubikey luks single factor decryption.
        See the following gist for setup example:
        https://gist.github.com/heywoodlh/4cc0254359b173ba9f9a1ea8f3b2e49f
      '';
      type = bool;
    };
    fido = mkOption {
      default = false;
      description = ''
        Use FIDO device decryption.
        Setup with: `sudo systemd-cryptenroll /dev/nvme0n1p2 --fido2-device=auto --fido2-with-user-presence=yes --fido2-with-client-pin=no`
      '';
      type = bool;
    };
  };

  config = mkIf cfg.enable {
    boot.initrd = {
      availableKernelModules = optionals (cfg.yubikey) [
        "vfat"
        "nls_cp437"
        "nls_iso8859-1"
      ];
      systemd = optionalAttrs (cfg.fido) {
        enable = true;
        fido2.enable = true;
      };
      luks = {
        yubikeySupport = cfg.yubikey;
        fido2Support = false; # Made obsolete by systemd-cryptenroll
        devices."${cfg.name}" = {
          fallbackToPassword = cfg.yubikey; # default of boot.initrd.systemd.enable = true
          device = "/dev/disk/by-uuid/${cfg.uuid}";
          yubikey = optionalAttrs (cfg.yubikey) {
            slot = 2;
            twoFactor = false;
            gracePeriod = 5;
            keyLength = 64;
            saltLength = 16;
            storage = {
              device = cfg.boot;
              fsType = "vfat";
              path = "/crypt-storage/default";
            };
          };
          crypttabExtraOpts = optionals (cfg.fido) [
            "fido2-device=auto"
            "token-timeout=30"
          ];
        };
      };
    };
  };
}
