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

    # Trim kernel config for hardware/subsystems none of the cachyos-kernel
    # machines have (nixos-gaming: AMD+Nvidia desktop; nixos-blade: Razer
    # Blade 14, AMD Ryzen APU w/ integrated Radeon + Nvidia dGPU;
    # nixos-framework: Intel-only, no discrete GPU). Only disables things
    # that are safe on all three — does NOT touch DRM_AMDGPU (needed by the
    # Razer Blade's integrated graphics), Wi-Fi vendor drivers (chipset
    # varies per machine and isn't tracked here), or debug-info/BTF/
    # SCHED_CLASS_EXT (cachyos is often chosen for sched-ext schedulers on
    # gaming machines).
    boot.kernelPatches = [
      {
        name = "cachyos-trim-unused-drivers";
        patch = null;
        structuredExtraConfig = let
          no = lib.mkForce lib.kernel.no;
          # Orphaned children of the disabled parents below: force off, but
          # keep optional so the now-orphaned symbol is a warning, not a
          # hard error.
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
