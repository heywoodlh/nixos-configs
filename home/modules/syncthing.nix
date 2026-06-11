
{ config, lib, pkgs, gitignore, ... }:

with lib;
let
  cfg = config.heywoodlh.home.syncthing;
  readIgnoreFile =
    path:
    builtins.filter (line: line != "" && !lib.hasPrefix "#" line && !lib.hasPrefix "Icon[" line) (
      lib.splitString "\n" (builtins.readFile path)
    );
in {
  options = {
    heywoodlh.home.syncthing = mkOption {
      default = false;
      description = ''
        Enable heywoodlh syncthing configuration.
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.file."opt/.stignore".text = ''
      result/**
      .direnv/**
    '';

    home.file."Pictures/.stignore".text = ''
      ### macOS ###
      .AppleDouble
      .LSOverride
      Icon
      ._*
      .DocumentRevisions-V100
      .fseventsd
      .Spotlight-V100
      .TemporaryItems
      .Trashes
      .VolumeIcon.icns
      .com.apple.timemachine.donotpresent
      .AppleDB
      .AppleDesktop
      Network Trash Folder
      Temporary Items
      .apdisk
      # iCloud generated files
      *.icloud
      .DS_Store   # Finder metadata file
      ._*         # AppleDouble metadata files (created when copying to non-Mac file systems)
      .AppleDouble # Apple resource fork storage
      .fseventsd   # File system events log directory
      .Spotlight-V100  # Spotlight search index files
      .Trashes    # Trash folder files
      .VolumeIcon.icns  # Custom volume icons
      *.app/      # macOS applications (bundles)
      *.dmg       # macOS disk image files
      *.pkg       # macOS installer packages
      *.sparsebundle  # Mac encrypted disk image format
      *.sparseimage   # Mac disk image format
      *.mobileconfig  # Mac configuration profiles
    '';

    services.syncthing = {
      enable = true;
      settings.options = {
        globalAnnounceEnabled = false;
        localAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = (-1);
        announceLANAddresses = false;
      };
    };
  };
}
