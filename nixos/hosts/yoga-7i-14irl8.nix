{ config, lib, pkgs, lanzaboote, ... }:

let
  egis0576-src = pkgs.fetchFromGitHub {
    owner = "PHILIPPDEV5396";
    repo = "libfprint-egis0576";
    rev = "33f9d8beb83ffc2b513507ab724d675469348713";
    hash = "sha256-B6lkYLAsD2uIAVIeXWxnNl5YxVChqoJQNVi4AfWUajA=";
  };

  libfprint-egis0576 = pkgs.libfprint.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      cp ${egis0576-src}/driver/egis0576.c ${egis0576-src}/driver/egis0576.h libfprint/drivers/
      cp -r ${egis0576-src}/driver/egis0576 libfprint/drivers/
      chmod -R u+w libfprint/drivers/egis0576
      patch -p1 < ${egis0576-src}/patches/libfprint-${old.version}-egis0576.patch
      substituteInPlace libfprint/fprint-list-udev-hwdb.c \
        --replace-fail "  { .vid = 0x1c7a, .pid = 0x0576 },
" ""
    '';
  });

  chargeLimit = "80.0";

  ashell-scaled = pkgs.ashell.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/services/upower/dbus.rs \
        --replace-fail "return Ok(pct);" "return Ok((pct * 100.0 / ${chargeLimit}).min(100.0));"
    '';
  });
in
{
  imports = [ lanzaboote.nixosModules.lanzaboote ];

  fileSystems."/" =
    { device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };

  heywoodlh.luks = {
    enable = true;
    name = "cryptroot";
    uuid = "24e64e22-2978-43a7-9ec8-57585f5aeb79";
    tpm2 = true;
  };

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    autoEnrollKeys.enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  users.users.heywoodlh.extraGroups = [ "tss" ];

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/DDAC-B67A";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/212bbfbd-3c06-42d0-9cc3-e29f25a76dac"; }
    ];

  boot.initrd.availableKernelModules = [
    "nvme" "xhci_pci" "thunderbolt" "usb_storage" "uas" "sd_mod" "usbhid" "sdhci_pci"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "pcie_aspm.policy=powersupersave" "i915.enable_psr=0" ];
  hardware.intelgpu.vaapiDriver = "intel-media-driver";
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.firmware = [ pkgs.sof-firmware ];
  # Bass speaker quirk confirmed for Yoga 7i Gen 6/7; enable if speakers
  # sound thin on this unit:
  # boot.extraModprobeConfig = ''
  #   options snd-sof-intel-hda-generic hda_model=alc287-yoga9-bass-spk-pin
  # '';

  # Thermal management for the Raptor Lake CPU
  services.thermald.enable = true;

  # Firmware updates (BIOS/SSD/etc.)
  services.fwupd.enable = true;

  # 2-in-1 convertible: accelerometer + tablet-mode switch via iio-sensor-proxy
  environment.systemPackages = with pkgs; [ iio-sensor-proxy sbctl ];

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  systemd.services.battery-charge-limit = {
    description = "Limit battery charging to extend battery lifespan";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      threshold_set=0
      for bat in /sys/class/power_supply/BAT*; do
        if [ -w "$bat/charge_control_end_threshold" ]; then
          echo 80 > "$bat/charge_control_end_threshold"
          threshold_set=1
        fi
      done
      if [ "$threshold_set" = 0 ]; then
        for dev in /sys/bus/platform/drivers/ideapad_acpi/*; do
          if [ -w "$dev/conservation_mode" ]; then
            echo 1 > "$dev/conservation_mode"
          fi
        done
      fi
    '';
  };

  systemd.services."systemd-backlight@leds:platform::kbd_backlight" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStartPost = "${pkgs.runtimeShell} -c 'cat /sys/class/leds/platform::kbd_backlight/max_brightness > /sys/class/leds/platform::kbd_backlight/brightness'";
  };

  # Fingerprint login
  security.pam.services.sudo.fprintAuth = true;
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override { libfprint = libfprint-egis0576; };
  };

  home-manager.users.heywoodlh.programs.ashell.package = ashell-scaled;

  home-manager.users.heywoodlh.wayland.windowManager.hyprland.extraConfig = ''
    -- change monitor to high resolution, the last argument is the scale factor
    hl.monitor({ output = "", mode = "highres", position = "auto", scale = 1.6 })
    -- unscale XWayland
    hl.config({ xwayland = { force_zero_scaling = true } })
    -- toolkit-specific scale
    hl.env("GDK_SCALE", "2")
    hl.env("XCURSOR_SIZE", "24")
  '';
}
