{ config, pkgs, ... }:

let
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
    mkdir -p ~/.steam/root/compatibilitytools.d

    # extract proton tarball to steam directory
    tar -xf $tarball_name -C ~/.steam/root/compatibilitytools.d/
  '';
in {
  environment.systemPackages = [ get-proton-ge ];
}
