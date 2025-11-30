{ pkgs, lib, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in {
  programs.steam = {
    enable = system == "x86_64-linux";
    protontricks.enable = true;
  };

  environment.systemPackages = let
    fexRunner = pkgs.writeShellScriptBin "fex-run" ''
      if [[ ! -e $HOME/.fex-emu/RootFS/Ubuntu_24_04.sqsh ]]
      then
        ${pkgs.libnotify}/bin/notify-send "Downloading rootfs for Steam"
        ${pkgs.fex}/bin/FEXRootFSFetcher --distro-name "ubuntu" --distro-version "24.04" -y -x
      fi

      ${pkgs.muvm}/bin/muvm \
        --mount opengl:/run/opengl-driver:/run/opengl-driver \
        --mount tmp:/tmp:/tmp \
        --systemd-udevd-path /usr/lib/systemd/systemd-udevd \
        -- $@
    '';
  in lib.optionals (system == "aarch64-linux") [
    pkgs.fex
    pkgs.fuse
    pkgs.muvm
    pkgs.squashfuse
    pkgs.steam-unwrapped
    fexRunner
    (pkgs.writeShellScriptBin "steam" ''
      # for fex rootfs fetcher
      STEAMDIR=$HOME/.local/share/Steam
      mkdir -p $STEAMDIR

      [[ -e $STEAMDIR/ubuntu12_32/steam ]] || tar -C $STEAMDIR -xvf ${pkgs.steam-unwrapped}/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
      ${fexRunner}/bin/fex-run $HOME/.local/share/Steam/ubuntu12_32/steam
    '')
  ];

  hardware.bluetooth.input = {
    General = {
      UserspaceHID = true;
      ClassicBondedOnly = false;
      LEAutoSecurity = false;
    };
  };
  boot.kernelModules = [
    "hid_microsoft" # Xbox One Elite 2 controller driver preferred by Steam
    "uinput"
  ];
  # https://github.com/ValveSoftware/steam-for-linux/issues/9310#issuecomment-2166248312
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "xbox-one-elite-2-udev-rules";
      text = ''KERNEL=="hidraw*", TAG+="uaccess"'';
      destination = "/etc/udev/rules.d/60-xbox-elite-2-hid.rules";
    })
  ];
}

