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

<details>

For VMs, use the NixOS graphical installer.

#### VMWare VMs:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-vmware --impure
```

#### UTM VMs:

Use the following settings when setting up the VM:

Virtualize > Use Apple Virtualization > Enable Rosetta (x86_64 Emulation)

Use the `copy-to-ram` install option, then run through the graphical installer.

After the install, run the following command:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-utm --impure
```

</details>

### MacOS:

To install a MacOS configuration, let's assume the `m3-macbook-pro` output, do the following:

```
nix run "github:LNL7/nix-darwin#packages.aarch64-darwin.darwin-rebuild" -- switch --flake github:heywoodlh/nixos-configs#m3-macbook-pro --impure
```


### Other Linux distributions:

Run the following command to use the Home Manager implementation on any Linux distribution with `nix` installed:

```
nix --extra-experimental-features 'nix-command flakes' run github:heywoodlh/nixos-configs#homeConfigurations.heywoodlh.activationPackage --impure
```

For headless Linux machines:

```
nix --extra-experimental-features 'nix-command flakes' run github:heywoodlh/nixos-configs#homeConfigurations.heywoodlh-server.activationPackage --impure
```
