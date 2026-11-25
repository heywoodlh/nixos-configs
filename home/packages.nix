{
  pkgs,
  name,
}: let
  homeSwitch = pkgs.writeShellScriptBin "home-switch" ''
    if [[ -d $HOME/opt/nixos-configs ]]
    then
      target="$HOME/opt/nixos-configs"
    else
      target="git+https://tangled.org/heywoodlh.io/nixos-configs"
    fi
    EXTRA_ARGS=""
    if ${pkgs.gnugrep}/bin/grep -iq Ubuntu /etc/os-release
    then
      version="$(${pkgs.gnugrep}/bin/grep VERSION_ID /etc/os-release | ${pkgs.coreutils}/bin/cut -d'=' -f2 | ${pkgs.coreutils}/bin/tr -d '"')"
      if echo "$version" | ${pkgs.gnugrep}/bin/grep -qE '22'
      then
        EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-22.05"
      fi
      if echo "$version" | ${pkgs.gnugrep}/bin/grep -qE '23'
      then
        EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-23.05"
      fi
      if echo "$version" | ${pkgs.gnugrep}/bin/grep -q '24|25'
      then
        EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-24.05"
      fi
      if echo "$version" | ${pkgs.gnugrep}/bin/grep -q '26'
      then
        EXTRA_ARGS="--override-input nixpkgs-lts github:nixos/nixpkgs/nixos-26.05"
      fi
    fi
    ${pkgs.nix}/bin/nix --extra-experimental-features 'nix-command flakes' run "$target#homeConfigurations.${name}.activationPackage" $EXTRA_ARGS --impure $@
  '';
in [homeSwitch]
