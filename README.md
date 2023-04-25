## NixOS Configs

This repo stores my NixOS and Nix on Darwin setup.

NixOS configs are here: [./nixos](./nixos)

Nix on Darwin configs are here: [./darwin](./darwin)

## How to Use

Check out the outputs for this flake with this command:

```
nix flake show github:heywoodlh/nixos-configs
```

For some reason, the `darwinConfigurations` outputs aren't shown properly, so you'll have to manually check out `./flake.nix` to figure out what MacOS outputs are available.

### NixOS:

To install a NixOS configuration, let's assume the `nixos-desktop-intel` output, do the following:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-desktop-intel
```

### MacOS:

> Note: currently there is a bug with how `darwin-rebuild` is parsing URIs, so this command will not work until that is fixed: https://github.com/LnL7/nix-darwin/pull/600

To install a MacOS configuration, let's assume the `macos-desktop-intel` output, do the following:

```
darwin-rebuild switch --flake github:heywoodlh/nixos-configs#macos-desktop-intel
```


### Other Linux distributions:

Run the following command to use the Home Manager implementation on any Linux distribution with `nix` installed:

```
nix --extra-experimental-features "nix-command flakes" run github:heywoodlh/nixos-configs#homeConfigurations.heywoodlh.activationPackage
```
