{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.heywoodlh.apple-silicon;
  username = config.heywoodlh.defaults.user.name;
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
  };
}
