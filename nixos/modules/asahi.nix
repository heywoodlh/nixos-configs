{ config, pkgs, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.apple-silicon;
  username = config.heywoodlh.defaults.user.name;
  steamType = submodule {
    options = {
      enable = mkOption {
        default = true;
        description = ''
          Enable Steam for Asahi.
        '';
        type = bool;
      };
      user = mkOption {
        default = "heywoodlh";
        description = ''
          User for Steam configuration.
        '';
        type = str;
      };
      memory = mkOption {
        default = 0;
        description = ''
          Memory allowed for Steam. Set to 6144 for 8GB machines.
        '';
        type = int;
      };
    };
  };
in {
  options.heywoodlh.apple-silicon = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh apple-silicon configuration.
      '';
      type = types.bool;
    };
    cachefile = mkOption {
      default = "";
      description = ''
        Asahi Linux cache file name in `/boot`.
      '';
    };
    firmwarefile = mkOption {
      default = "all_firmware.tar.gz";
      description = ''
        Asahi Linux all firmware file name in `/boot`.
      '';
    };
    hash = let
      hashType = submodule {
        options = {
          cache = mkOption {
            description = ''
              Hash for kernel cache.
              Retrieve with `nix hash convert --hash-algo sha256 $(nix-prefetch-url file:///boot/asahi/<cachefile>)`.
            '';
            default = "";
            type = str;
          };
          firmware = mkOption {
            description = ''
              Hash for firmware file.
              Retrieve with `nix hash convert --hash-algo sha256 $(nix-prefetch-url file:///boot/asahi/all_firmware.tar.gz)`.
            '';
            default = "";
            type = str;
          };
        };
      };
    in mkOption {
      default = {};
      description = "Hashes for firmware files.";
      type = hashType;
    };
    steam = mkOption {
      description = "Enable Asahi Steam configuration.";
      type = steamType;
    };
  };

  config = mkIf (cfg.enable) {
    kyle.appleSilicon = {
      enable = true;
      kernelcache = {
        name = cfg.cachefile;
        hash = cfg.hash.cache;
      };
      allfirmware = {
        name = cfg.firmwarefile;
        hash = cfg.hash.firmware;
      };
    };
    home-manager.users.${username} = {
      heywoodlh.home.onepassword.gpu = false;
    };

    environment.systemPackages = let
      reboot-macos = pkgs.writeShellScriptBin "reboot-macos" ''
        sudo ${pkgs.asahi-bless}/bin/asahi-bless --next --set-boot 1 -y && sudo reboot
      '';
    in with pkgs; [
      asahi-bless
      reboot-macos
    ];

    programs.steam-asahi = optionalAttrs (cfg.steam.enable) {
      enable = true;
      memoryMiB = mkIf (cfg.steam.memory != 0) cfg.steam.memory;
    };
    # steam-asahi muvm is rootless, but needs /dev/kvm access.
    users.users."${cfg.steam.user}".extraGroups = optionalAttrs (cfg.steam.enable) [ "kvm" ];

    boot = optionalAttrs (cfg.steam.enable) {
      kernelParams = [
        "zswap.enabled=1"
        "zswap.compressor=zstd"
        "zswap.zpool=zsmalloc"
        "zswap.max_pool_percent=20"
      ];
      kernel.sysctl = {
        "vm.swappiness" = 100;
        "vm.page-cluster" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.max_map_count" = 1048576;
      };
    };
  };
}
