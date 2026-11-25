{
  config,
  pkgs,
  myPkgs,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;
  homeDir = config.home.homeDirectory;
in {
  home.file.".local/share/applications/spotify.desktop" = {
    enable = system == "aarch64-linux";
    text = ''
      [Desktop Entry]
      Name=Spotify
      GenericName=music
      Comment=Listen to Spotify
      Exec=${myPkgs.chromium-widevine}/bin/chromium --app=https://open.spotify.com
      Terminal=false
      Type=Application
      Keywords=music;
      Icon=${homeDir}/.icons/snowflake.png
      Categories=Music;
    '';
  };
}
