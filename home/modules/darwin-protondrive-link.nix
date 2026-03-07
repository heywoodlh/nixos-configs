{ config, lib, ... }:

with lib;

let
  cfg = config.heywoodlh.home.darwin.protondrive;
  homeDir = config.home.homeDirectory;
in {
  options = {
    heywoodlh.home.darwin.protondrive = mkOption {
      default = false;
      description = ''
        Symlink ProtonDrive accounts to $HOME/mnt/protondrive-*
      '';
      type = types.bool;
    };
  };

  config = mkIf cfg {
    home.activation.protondrive-link = ''
      mkdir -p "${homeDir}"/mnt
      if [[ -e "${homeDir}"/Library/CloudStorage ]]
      then
        for file in "${homeDir}"/Library/CloudStorage/ProtonDrive-*
        do
          account="$(eval basename "$file" | cut -d'-' -f2 | cut -d'-' -f3)"
          dest="${homeDir}/mnt/protondrive-$account"
          [[ -e "$dest" ]] || ln -sv $file $dest
        done
      fi
    '';
  };
}
