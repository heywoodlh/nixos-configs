{ pkgs, config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.gaming;
  system = pkgs.stdenv.hostPlatform.system;
  get-proton-ge = pkgs.writeShellScriptBin "proton-ge.sh" ''
    set -ex
    export PATH="${pkgs.coreutils}/bin:${pkgs.curl}/bin:${pkgs.gnutar}/bin:$PATH"
    # make temp working directory
    rm -rf /tmp/proton-ge-custom
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom

    # download tarball
    tarball_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)
    tarball_name=$(basename $tarball_url)
    curl -# -L $tarball_url -o $tarball_name --no-progress-meter

    # download checksum
    checksum_url=$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)
    checksum_name=$(basename $checksum_url)
    curl -# -L $checksum_url -o $checksum_name --no-progress-meter

    # check tarball with checksum
    sha512sum -c $checksum_name
    # if result is ok, continue

    # make steam directory if it does not exist
    mkdir -p $HOME/.steam/root/compatibilitytools.d

    # extract proton tarball to steam directory
    tar -xf $tarball_name -C $HOME/.steam/root/compatibilitytools.d/
  '';
  fexFetcher = pkgs.writeShellScriptBin "fex-fetch.sh" ''
    if [[ ! -e $HOME/.fex-emu/RootFS/Ubuntu_24_04.sqsh ]]
    then
      ${pkgs.libnotify}/bin/notify-send "Downloading rootfs for Steam"
      ${pkgs.fex}/bin/FEXRootFSFetcher --distro-name "ubuntu" --distro-version "24.04" -y -x
    else
      ${pkgs.libnotify}/bin/notify-send "FEX rootfs for Steam already downloaded at $HOME/.fex-emu/RootFS/Ubuntu_24_04.sqsh"
    fi
  '';
in {
  options.heywoodlh.nixos.gaming = mkOption {
    default = false;
    description = ''
      Enable heywoodlh gaming configuration.
    '';
    type = types.bool;
  };

  config = mkIf cfg {
    programs.steam = {
      enable = true;
      package = if (system == "aarch64-linux") then
        vidhanix.packages.${system}.muvm-steam
      else pkgs.steam;
      protontricks.enable = (system == "x86_64-linux");
      gamescopeSession.enable = false;
      localNetworkGameTransfers.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      get-proton-ge
    ] ++ lib.optionals (system == "aarch64-linux") [
      fex
      fuse
      muvm
      squashfuse
      fexFetcher
    ];

    # FUSE required for FEX (FEX is part of muvm-steam)
    programs.fuse = lib.optionalAttrs (system == "aarch64-linux") {
      enable = true;
      userAllowOther = true;
    };

    hardware = {
      graphics = lib.optionalAttrs (system == "aarch64-linux") {
        enable32Bit = lib.mkForce false;
      };
      bluetooth.input = {
        General = {
          UserspaceHID = true;
          ClassicBondedOnly = false;
          LEAutoSecurity = false;
        };
      };
      steam-hardware.enable = true;
    };

    powerManagement.scsiLinkPolicy = "max_performance";

    boot = {
      kernel.sysctl = {
        "vm.swappiness" = 150;
        "vm.vfs_cache_pressure" = 50;
        "vm.dirty_bytes" = 268435456;
        "vm.page-cluster" = 0;
        "vm.dirty_background_bytes" = 67108864;
        "vm.dirty_writeback-centisecs" = 1500;
        "kernel.nmi_watchdog" = 0;
        "kernel.unprivileged_userns_clone" = 1;
        "kernel.kptr_restrict" = 2;
        "net.core.netdev_max_backlog" = 4096;
        "fs.file-max" = 2097152;
      };
      extraModprobeConfig = ''
        blacklist sp5100_tco
      '';
      kernelModules = [
        "hid_microsoft" # Xbox One Elite 2 controller driver preferred by Steam
        "uinput"
        "bfq"
      ] ++ lib.optionals (system == "aarch64-linux") [
        "fuse"
      ];
    };
    services.udev = {
      extraRules = ''
        ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", \
            ATTR{queue/scheduler}="bfq"
        ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", \
            ATTR{queue/scheduler}="mq-deadline"
        ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", \
            ATTR{queue/scheduler}="none"
        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
        ATTRS{id/bus}=="ata", RUN+="${pkgs.hdparm}/bin/hdparm -B 254 -S 0 /dev/%k"
      '';
      packages = [
        (pkgs.writeTextFile {
          name = "xbox-one-elite-2-udev-rules";
          text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
          destination = "/etc/udev/rules.d/60-xbox-elite-2-hid.rules";
        })
      ];
    };

    # Taken from https://github.com/CachyOS/CachyOS-Settings/blob/9c123e743a9b99b4ca1fcacc187ae0f223fcf098/usr/bin/pci-latency
    systemd.services.pci-latency = {
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.pciutils ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
      };
      script = ''
        echo "Resetting the latency timer for all PCI devices..."
        setpci -v -s '*:*' latency_timer=20
        setpci -v -s '0:0' latency_timer=0

        echo "Setting latency timer for all sound cards..."
        setpci -v -d "*:*:04xx" latency_timer=80

        echo "Done setting PCI latencies!"
      '';
    };

    systemd.services.pci-latency-on-resume = {
      wantedBy = [ "sleep.target" ];
      before = [ "sleep.target" ];
      serviceConfig.User = "root";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = "yes";
      unitConfig.StopWhenUnneeded = "yes";
      path = [ pkgs.coreutils pkgs.systemd ];
      script = "exit 0";
      postStop = ''
        echo "Restarting pci-latency service..."
        systemctl restart pci-latency
        echo "Done restarting pci-latency service!"
      '';
    };
  };
}
