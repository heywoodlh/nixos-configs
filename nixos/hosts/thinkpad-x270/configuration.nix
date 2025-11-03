# Config specific to Thinkpad X270
{ config, pkgs, nixpkgs-stable, lib, lanzaboote, nixos-hardware, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
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

  libfprint-2-tod1-vfs0090-overlay = self: super:
  {
    libfprint-2-tod1-vfs0090 =
      (super.libfprint-2-tod1-vfs0090.override {
        libfprint-tod = super.libfprint-tod.overrideAttrs (old: rec {
          version = "1.90.7+git20210222+tod1";
          src = old.src.overrideAttrs {
            rev = "v${version}";
            outputHash = "0cj7iy5799pchyzqqncpkhibkq012g3bdpn18pfb19nm43svhn4j";
            outputHashAlgo = "sha256";
          };
          buildInputs = (old.buildInputs or []) ++ [self.nss];
          mesonFlags = [
            "-Ddrivers=all"
            "-Dudev_hwdb_dir=${placeholder "out"}/lib/udev/hwdb.d"
          ];
        });
      })
      .overrideAttrs
      {meta.broken = false;};
  };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../desktop.nix
      ../../roles/monitoring/osquery.nix
      ../../roles/storage/icloud-sftp.nix
      lanzaboote.nixosModules.lanzaboote
      nixos-hardware.nixosModules.lenovo-thinkpad-x270
    ];

  nixpkgs.overlays = [ libfprint-2-tod1-vfs0090-overlay ];

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
    spotifyd
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
    enable = false;
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
    enable = false;
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
  services.fprintd = {
    enable = true;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-vfs0090;
    };
  };
  security.pam.services.login.fprintAuth = lib.mkForce true;
  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.gdm.fprintAuth = true;

  services.spotifyd.enable = true;
}
