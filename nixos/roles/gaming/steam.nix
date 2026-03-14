{ pkgs, lib, vidhanix, ... }:

let
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
  programs.steam = {
    enable = true;
    package = if (system == "aarch64-linux") then
      vidhanix.packages.${system}.muvm-steam
    else pkgs.steam;
    protontricks.enable = (system == "x86_64-linux");
    gamescopeSession.enable = true;
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

  boot.kernelModules = [
    "hid_microsoft" # Xbox One Elite 2 controller driver preferred by Steam
    "uinput"
  ] ++ lib.optionals (system == "aarch64-linux") [
    "fuse"
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
