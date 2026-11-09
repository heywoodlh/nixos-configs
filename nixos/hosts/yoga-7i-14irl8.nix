{ config, lib, pkgs, ... }:

let
  # Goodix GF3268 fingerprint sensor (USB 27c6:55b4) shipped in the Yoga 7i
  # Gen 8 (14IRL8/16IRL8). Stock libfprint does not support it; the
  # libfprint-goodix55b4-milan driver integrates into libfprint 1.94.10 /
  # 1.94.100 (pinned nixpkgs libfprint is exactly 1.94.100) with its own
  # integration script.
  # https://github.com/TheWeirdDev/libfprint-goodix55b4-milan
  #
  # After first build:
  #   - Confirm the reader with `lsusb` (expect 27c6:55b4).
  #   - Enroll with `sudo fprintd-enroll -f left-index-finger heywoodlh`.
  #   - If enrollment fails with "not provisioned with the zero PSK",
  #     follow the driver README's Sensor provisioning section (this
  #     breaks Windows Hello on dual-boot setups; Windows also reflashes
  #     the sensor, so disable the reader in Windows Device Manager).
  goodix55b4-src = pkgs.fetchFromGitHub {
    owner = "TheWeirdDev";
    repo = "libfprint-goodix55b4-milan";
    rev = "7b41f02e51875637641349bd826964c290e8553e";
    hash = "sha256-suZ44KNI6yYejF0cCtnYkXPsD1s2bCZuEAAdTBMHa78=";
  };

  libfprint-goodix55b4 = pkgs.libfprint.overrideAttrs (old: {
    buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.libdeflate ];
    postPatch = (old.postPatch or "") + ''
      ${pkgs.python3.interpreter} ${goodix55b4-src}/scripts/integrate.py .
    '';
  });
in
{

  fileSystems."/" =
    { device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/24e64e22-2978-43a7-9ec8-57585f5aeb79";

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
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
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
  environment.systemPackages = [ pkgs.iio-sensor-proxy ];

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

  # Fingerprint login
  security.pam.services.sudo.fprintAuth = true;
  services.fprintd = {
    enable = true;
    package = pkgs.fprintd.override { libfprint = libfprint-goodix55b4; };
  };

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
