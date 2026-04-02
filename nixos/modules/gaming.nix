{ pkgs, config, lib, vidhanix, ... }:

with lib;

let
  cfg = config.heywoodlh.nixos.gaming;
  system = pkgs.stdenv.hostPlatform.system;
  fexFetcher = pkgs.writeShellScriptBin "fex-fetch.sh" ''
    if [[ ! -e $HOME/.fex-emu/RootFS/Ubuntu_24_04.sqsh ]]
    then
      ${pkgs.libnotify}/bin/notify-send "Downloading rootfs for Steam"
      ${pkgs.fex}/bin/FEXRootFSFetcher --distro-name "ubuntu" --distro-version "24.04" -y -x
    else
      ${pkgs.libnotify}/bin/notify-send "FEX rootfs for Steam already downloaded at $HOME/.fex-emu/RootFS/Ubuntu_24_04.sqsh"
    fi
  '';
  get-custom-proton = pkgs.writeShellScriptBin "proton-custom.sh" ''
    export PATH="${pkgs.coreutils}/bin:${pkgs.curl}/bin:${pkgs.gnutar}/bin:${pkgs.gzip}/bin:${pkgs.xz}/bin:${pkgs.jq}/bin:$PATH"
    if [[ -z "$1" ]]
    then
      echo proton-cachyos usage: $0 "CachyOS/proton-cachyos"
      echo glorious-eggroll usage: $0 "GloriousEggroll/proton-ge-custom"
      exit 0
    else
      target="$1"
    fi

    if [[ "$target" != "CachyOS/proton-cachyos" ]] && [[ "$target" != "GloriousEggroll/proton-ge-custom" ]]
    then
      echo ERROR: must provide valid proton target
      echo proton-cachyos usage: $0 "CachyOS/proton-cachyos"
      echo glorious-eggroll usage: $0 "GloriousEggroll/proton-ge-custom"
      exit 0
    fi

    if [[ "$target" == "CachyOS/proton-cachyos" ]]
    then
      # https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-10.0-20260324-slr/proton-cachyos-10.0-20260324-slr-x86_64.tar.xz
      suffix="slr-x86_64.tar.xz"
      shasum_suffix="slr-x86_64.sha512sum"
    fi

    if [[ "$target" == "GloriousEggroll/proton-ge-custom" ]]
    then
      # https://github.com/GloriousEggroll/proton-ge-custom/releases/download/GE-Proton10-34/GE-Proton10-34.tar.gz
      suffix=".tar.gz"
      shasum_suffix=".sha512sum"
    fi

    STEAM_DIR="$HOME/.steam/root/compatibilitytools.d"
    release_tag=$(curl -s https://api.github.com/repos/$target/releases/latest | jq -r '.tag_name')
    if ls $STEAM_DIR | grep -q "$release_tag"
    then
      echo "Latest $target release already downloaded."
    else
      set -ex
      # make temp working directory
      rm -rf /tmp/proton-custom
      mkdir /tmp/proton-custom
      cd /tmp/proton-custom

      # download tarball
      tarball_url=$(curl -s https://api.github.com/repos/$target/releases/latest | grep browser_download_url | cut -d\" -f4 | grep $suffix)
      tarball_name=$(basename $tarball_url)
      curl -# -L $tarball_url -o $tarball_name --no-progress-meter

      # download checksum
      checksum_url=$(curl -s https://api.github.com/repos/$target/releases/latest | grep browser_download_url | cut -d\" -f4 | grep $shasum_suffix)
      checksum_name=$(basename $checksum_url)
      curl -# -L $checksum_url -o $checksum_name --no-progress-meter

      # check tarball with checksum
      sha512sum -c $checksum_name
      # if result is ok, continue

      # make steam directory if it does not exist
      mkdir -p "$STEAM_DIR"

      # extract proton tarball to steam directory
      tar -xf $tarball_name -C "$STEAM_DIR"
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
      localNetworkGameTransfers.openFirewall = true;
    };

    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };

    environment.systemPackages = with pkgs; [
      protonup-ng
    ] ++ lib.optionals (system == "x86_64-linux") [
      get-custom-proton
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
        "ntsync"
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
        (pkgs.writeTextFile {
          name = "ntsync-udev-rules";
          text = ''KERNEL=="ntsync", MODE="0660", TAG+="uaccess"'';
          destination = "/etc/udev/rules.d/70-ntsync.rules";
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

    home-manager.users.${config.heywoodlh.defaults.user.name}.home.activation.get-latest-proton = lib.optionalString (system == "x86_64-linux") ''
      # GloriousEggroll
      ${get-custom-proton}/bin/proton-custom.sh "GloriousEggroll/proton-ge-custom"
      # CachyOS proton
      ${get-custom-proton}/bin/proton-custom.sh "CachyOS/proton-cachyos"
    '';

    # Use Decky loader if Gamescope is enabled for Steam Deck like UX
    # Requires enabling CEF remote debugging on the Developer menu settings to work.
    jovian.decky-loader = {
      enable = true;
      user = config.heywoodlh.defaults.user.name;
      extraPackages = with pkgs; [
        power-profiles-daemon
        inotify-tools
        libpulseaudio
        coreutils
        gamescope
        gamemode
        mangohud
        pciutils
        systemd
        gnugrep
        python3
        gnused
        procps
        gawk
        file
      ];
      extraPythonPackages = pythonPkgs: with pythonPkgs; [
        click
      ];
    };
  };
}
