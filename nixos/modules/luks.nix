{ config, lib, pkgs, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.luks;

  # Fixed filename written to the root of the `keyfile` partition. Not
  # configurable: keeping it constant means the initrd crypttab entry and the
  # enrollment script always agree on where to look without needing another
  # option.
  keyFileName = "luks.key";

  keyfileType = submodule {
    options = {
      enable = mkOption {
        default = false;
        description = ''
          Enable fully-automatic decryption via a keyfile stored on an
          internal, already-mounted-at-boot partition (e.g. the EFI System
          Partition), with fallback to the password/FIDO2 slots if the
          keyfile is ever unreadable. No touch/interaction required, unlike
          `fido`.

          Security note: since the keyfile lives unencrypted on the same
          physical disk as the LUKS volume, this gives no protection against
          someone stealing the disk/machine and reading it directly -- only
          against remote/software access without ever booting this OS. Don't
          enable this if physical theft is a real threat model for this
          machine.

          Setup:
            read passphrase
            echo -n $passphrase | sudo tee /etc/luks-admin-key &>/dev/null
            sudo chmod 400 /etc/luks-admin-key
            # then: nixos-rebuild switch

          The activation script uses /etc/luks-admin-key to authorize
          enrolling a new keyfile (systemd-cryptenroll has no plain-keyfile
          mode, so this uses `cryptsetup luksAddKey`), then deletes
          /etc/luks-admin-key once enrolled. Re-stage that file before
          switching again if you need to re-enroll.
        '';
        type = bool;
      };
      uuid = mkOption {
        default = "";
        description = ''
          Filesystem UUID of the partition that stores the keyfile (not the
          LUKS device). Must be a partition systemd stage 1 can mount
          on its own, e.g. the EFI System Partition already used for
          `fileSystems."/boot"`. Obtain with `sudo blkid`.
        '';
        type = str;
      };
      path = mkOption {
        default = "/boot";
        description = ''
          Where that same filesystem is mounted in the running system
          (matching `uuid`). Used by the activation script to read/write the
          keyfile directly, since it's already mounted there -- no separate
          mount/unmount needed.
        '';
        type = str;
      };
      timeout = mkOption {
        default = 10;
        description = ''
          Seconds to wait for the keyfile's partition during boot before
          falling back to the other enrolled decryption methods.
        '';
        type = int;
      };
    };
  };
in {
  options.heywoodlh.luks = {
    enable = mkOption {
      default = false;
      description = ''
        Configure LUKS.
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

        Note: YubiKeys (and any FIDO2 authenticator implementing the hmac-secret
        extension) always enforce a touch/user-presence check at the hardware
        level, regardless of --fido2-with-user-presence. This is mandated by the
        CTAP2 spec, not configurable, and not something NixOS or systemd can
        override. If you need fully unattended decryption, use `keyfile` below
        instead.
      '';
      type = bool;
    };
    keyfile = mkOption {
      default = { };
      description = ''
        Automatic internal-keyfile decryption. See
        `heywoodlh.luks.keyfile.enable` for the full explanation and setup
        steps.
      '';
      type = keyfileType;
    };
  };

  config = mkIf cfg.enable {
    boot.initrd = {
      availableKernelModules = optionals (cfg.yubikey || cfg.keyfile.enable) [
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
          # `${keyFileName}:UUID=keyfile.uuid` tells systemd stage 1 to
          # auto-mount the internal block device with that UUID and read the
          # keyfile from its root. `timeout` bounds how long boot waits for
          # it before giving up and falling back to the other enrolled
          # slots.
          keyFile = mkIf cfg.keyfile.enable "/${keyFileName}:UUID=${cfg.keyfile.uuid}";
          keyFileTimeout = mkIf cfg.keyfile.enable cfg.keyfile.timeout;
          crypttabExtraOpts = optionals (cfg.fido) [
            "fido2-device=auto"
            "token-timeout=30"
          ];
        };
      };
    };

    # Auto-enrolls the `keyfile` the first time it's missing/invalid during
    # activation. Safe to run on every switch/boot: it's a no-op once the
    # keyfile is enrolled and still validates against the LUKS header. See
    # `keyfile.enable`'s doc above for the one-time manual setup this
    # depends on.
    system.activationScripts.luksKeyfileEnroll = mkIf cfg.keyfile.enable (
      lib.stringAfter [ "users" ] ''
        set -euo pipefail

        luksDevice="/dev/disk/by-uuid/${cfg.uuid}"
        adminKeyFile="/etc/luks-admin-key"
        keyFilePath="${cfg.keyfile.path}/${keyFileName}"

        if [ -f "$keyFilePath" ] && ${pkgs.cryptsetup}/bin/cryptsetup open --test-passphrase --key-file "$keyFilePath" "$luksDevice" 2>/dev/null; then
          exit 0
        fi

        if [ ! -e "$adminKeyFile" ]; then
          echo "luks-keyfile-enroll: $adminKeyFile not found, skipping automatic keyfile enrollment" >&2
          exit 0
        fi

        echo "luks-keyfile-enroll: enrolling new decryption keyfile at $keyFilePath" >&2
        umask 077
        tmpKey="$(${pkgs.coreutils}/bin/mktemp)"
        ${pkgs.coreutils}/bin/head -c 64 /dev/urandom > "$tmpKey"
        ${pkgs.cryptsetup}/bin/cryptsetup luksAddKey "$luksDevice" "$tmpKey" --key-file "$adminKeyFile"
        ${pkgs.coreutils}/bin/mv "$tmpKey" "$keyFilePath"
        ${pkgs.coreutils}/bin/chmod 400 "$keyFilePath"

        echo "luks-keyfile-enroll: enrolled, removing $adminKeyFile" >&2
        ${pkgs.coreutils}/bin/rm -f "$adminKeyFile"
      ''
    );
  };
}
