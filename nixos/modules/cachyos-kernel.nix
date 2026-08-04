{ pkgs, config, lib, nix-cachyos-kernel, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.cachyos-kernel;
in {
  options.heywoodlh.nixos.cachyos-kernel = {
    enable = mkOption {
      default = false;
      description = ''
        Enable heywoodlh cachyos-kernel configuration.
      '';
      type = types.bool;
    };
    kernel = mkOption {
      default = "linuxPackages-cachyos-latest-zen4";
      description = ''
        Desired CachyOS kernel version.
      '';
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    boot.kernelPackages = pkgs.cachyosKernels.${cfg.kernel};

    nixpkgs.overlays = [
      # 'default' overlay will be exposing absolute latest kernel
      # 'pinned' overlay is stabler and will always be cached
      # nix-cachyos-kernel.overlays.default
      nix-cachyos-kernel.overlays.pinned
    ];
    nix.settings = {
      substituters = [
        "https://attic.xuyh0120.win/lantian"
        "https://cache.xinux.uz"
      ];
      trusted-public-keys = [
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
        "cache.xinux.uz:BXCrtqejFjWzWEB9YuGB7X2MV4ttBur1N8BkwQRdH+0="
      ];
    };
  };
}
