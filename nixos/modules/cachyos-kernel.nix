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
    boot.kernelPatches = [
      {
        name = "cachyos-trim-unused-drivers";
        patch = null;
        structuredExtraConfig = let
          no = lib.mkForce lib.kernel.no;
          noOpt = lib.mkForce (lib.kernel.option lib.kernel.no);
        in {
          DRM_NOUVEAU_SVM = noOpt; # DRM_NOUVEAU
          INFINIBAND_IPOIB = noOpt; # INFINIBAND
          INFINIBAND_IPOIB_CM = noOpt;
          MEDIA_ATTACH = noOpt; # MEDIA_*_TV_SUPPORT / MEDIA_SDR_SUPPORT

          # Nvidia GPUs here always run the proprietary driver (nvidia-patch);
          # the open-source nouveau driver is never loaded.
          DRM_NOUVEAU = no;
          # Legacy pre-GCN AMD, superseded by amdgpu on all current hardware.
          DRM_RADEON = no;
          # Server BMC graphics.
          DRM_AST = no;
          DRM_MGAG200 = no;

          # TV tuners / DVB / SDR (keep MEDIA_CAMERA_SUPPORT for USB webcams
          # and capture devices like Sunshine).
          MEDIA_ANALOG_TV_SUPPORT = no;
          MEDIA_DIGITAL_TV_SUPPORT = no;
          MEDIA_SDR_SUPPORT = no;

          # Enterprise/legacy subsystems with zero relevance on gaming
          # desktops/laptops.
          COMEDI = no; # lab data-acquisition cards
          CAN = no; # automotive bus
          INFINIBAND = no; # RDMA / enterprise fabric
          ATM = no; # legacy WAN
          NFC = no;
        };
      }
    ];

    nixpkgs.overlays = [
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
