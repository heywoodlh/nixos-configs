# Config specific to Thinkpad X270
{ config, pkgs, nixpkgs-stable, lib, lanzaboote, nixos-hardware, x270-fingerprint-driver, ... }:

let
  system = pkgs.system;
  stable-pkgs = import nixpkgs-stable {
    inherit system;
    config.allowUnfree = true;
  };
  cpuThrottleFix = pkgs.writeShellScript "cpu-throttle-fix.sh" ''
    # https://superuser.com/a/1525797
    sleep 3 # Wait for system to settle
    # Determine CPU capabilities
    MAX_CPU=$(${pkgs.linuxKernel.packages.linux_xanmod_stable.cpupower}/bin/cpupower frequency-info -l | ${pkgs.coreutils}/bin/tail -n1 | ${pkgs.coreutils}/bin/cut -d' ' -f2)

    # Disable "BD PROCHOT"
    ${pkgs.msr-tools}/bin/wrmsr -a 0x1FC 262238;

    # Set and apply frequencies
    ${pkgs.linuxKernel.packages.linux_xanmod_stable.cpupower}/bin/cpupower frequency-set \
      -d $(expr $MAX_CPU / 2) \
      -u $MAX_CPU \
      -r \
      -g performance;
  '';
  # For manually running
  cpuThrottleFixWrapper = pkgs.writeShellScriptBin "cpu-throttle-fix-wrapper" ''
    sudo ${cpuThrottleFix}
  '';
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../console.nix
      ../../roles/monitoring/osquery.nix
      lanzaboote.nixosModules.lanzaboote
      nixos-hardware.nixosModules.lenovo-thinkpad-x270
      x270-fingerprint-driver.nixosModules."06cb-009a-fingerprint-sensor"
    ];

  # Bootloader
  boot.loader.systemd-boot.enable = false; # using lanzaboote
  boot.loader.efi.canTouchEfiVariables = true;
  hardware.enableRedistributableFirmware = true; # enable firmware
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;

  networking.hostName = "nixos-thinkpad"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "America/Denver";

  # Configuration for this machine
  home-manager.users.heywoodlh = {
    home.packages = with pkgs; [
      stable-pkgs.beeper
      gimp
      moonlight-qt
      stable-pkgs.legcord
      stable-pkgs.rustdesk
      zoom-us
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    #clevis
    lanzaboote
    sbctl
    cpuThrottleFixWrapper
  ];

  # Hard limits for Nix
  nix.settings = {
    cores = 2;
    max-jobs = 2;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Automate LUKS decryption with TPM2 with this command:
  # sudo systemd-cryptenroll --wipe-slot tpm2 --tpm2-device auto --tpm2-with-pin=no --tpm2-pcrs "7" /dev/nvme0n1p2
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.tpm2.enable = true;
  security.tpm2.enable = true;
  security.tpm2.pkcs11.enable = true;
  security.tpm2.tctiEnvironment.enable = true;
  # Secure boot
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };
  users.users.heywoodlh.extraGroups = [ "tss" ];

  # Hardware accelerated graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  services.acpid = {
    enable = true;
    acEventCommands = ''
      # Ensure CPU is always at maximum performance
      ${cpuThrottleFix}
    '';
  };

  # Run CPU throttle fix on boot
  systemd.services.cpu-throttle-fix = {
    wantedBy = [ "multi-user.target" ];
    enable = true;
    serviceConfig = {
      User = "root";
      Group = "root";
      Type = "oneshot";
    };
    script = "${cpuThrottleFix}";
  };

  # To get ICCID, enable below for modemmanager to run in debug mode and then run the following command:
  # mmcli -m 0 --command AT^ICCID
  systemd.services.ModemManager = {
    enable = true;
    wantedBy = ["multi-user.target" "network.target"];
    # For debugging
    serviceConfig.ExecStart = ["" "${pkgs.modemmanager}/sbin/ModemManager --debug"];
  };

  # Get IMEI with this command: mmcli -m 0 | grep -i imei
  # Get ICCID with this command: mmcli --sim 0 | grep -i iccid
  networking.modemmanager.fccUnlockScripts = [
    rec {
      id = "1199:9079";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/${id}";
    }
  ];

  systemd.paths.setup_wwan = {
    wantedBy = [ "ModemManager.service" "network.target" ];
    pathConfig.PathExists = "/dev/cdc-wdm0";
  };
  systemd.services.setup_wwan = {
    script = ''
      ${pkgs.libqmi}/bin/qmicli -p -d /dev/cdc-wdm0 --device-open-mbim --dms-set-fcc-authentication
    '';
    before = [ "ModemManager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Fingerprint reader support
  #services.fprintd.enable = true;
  #services.fprintd.tod.enable = true;
  # https://github.com/ahbnr/nixos-06cb-009a-fingerprint-sensor/blob/24.11/SETUP-24.11.md#setup-based-on-fprintd-and-bingchs-driver
  # First, enable the python-validity service below, then run:
  #   ```
  #   systemctl stop python3-validity
  #   validity-sensors-firmware
  #   systemctl start python3-validity
  #   fprintd-enroll
  #   fprintd-enroll -f "right-middle-finger"
  #   ```
  # Then disable the python-validity service below and enable the libfprint-tod service below.
  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    backend = "python-validity";
  };
  #services."06cb-009a-fingerprint-sensor" = {
  #  enable = true;
  #  backend = "libfprint-tod";
  #  calib-data-file = /var/lib/python-validity/calib-data.bin;
  #};
}
