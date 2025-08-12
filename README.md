## NixOS Configs

This repo stores my NixOS and Nix on Darwin setup.

NixOS configs are here: [./nixos](./nixos)

Nix on Darwin configs are here: [./darwin](./darwin)

## Using custom modules

My custom modules expose a `heywoodlh` configuration parameter. Here's an incomplete example snippet for using my modules in a flake:

```
{
  description = "heywoodlh nix config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin/master";
    heywoodlh-configs.url = "/Users/heywoodlh/opt/nixos-configs";
  };

  outputs = inputs@{ self, nixpkgs, darwin, heywoodlh-configs, ... }: {

    darwinConfigurations = let
      heywoodlh-darwin-modules = (heywoodlh-configs + "/darwin/modules/default.nix");
    in {
      "my-macbook" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs;
        modules = [

          heywoodlh-darwin-modules

          {
            networking.hostName = "my-macbook";

            heywoodlh.darwin.sketchybar.enable = true;
            heywoodlh.darwin.yabai.enable = true;
            system.stateVersion = 4;
          }
        ];
      };
    };
  };
}
```

Documentation for module options can be viewed here: [options.md](./docs/options.md)

## How to Use

Check out the outputs for this flake with this command:

```
nix flake show github:heywoodlh/nixos-configs
```

For some reason, the `darwinConfigurations` outputs aren't shown properly, so you'll have to manually check out `./flake.nix` to figure out what MacOS outputs are available.

### NixOS:

To install a NixOS configuration, let's assume the `nixos-desktop-intel` output, go through the NixOS graphical installer and then run the following commands:

```
# Initial config to setup Attic cache, enable Tailscale and enable unconfigured Neovim
sudo nixos-rebuild switch --impure --flake github:heywoodlh/nixos-configs#nixos-init

# Tailscale for Attic cache
sudo tailscale up --qr --advertise-tags="tag:adminworkstation"
```

Then deploy the desired configuration:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-desktop-intel
```

<details>

#### VMWare VMs:

Then run the install on the virtual machine:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-vmware --impure
```

Make the following settings changes to the VM in VMWare Fusion:

Display:
  - [x] Accelerate 3D Graphics
    - Shared graphics memory => maximum
  - [x] Use full resolution for Retina display

Keyboard and Mouse:
  - Disable all host keybindings

Remove the Camera and Sound devices

Sharing:
  - [x] Enable Shared Folders
    - Add MacOS `$HOME`


#### UTM VMs:

Use the following settings when setting up the VM:

Virtualize > Use Apple Virtualization > Enable Rosetta (x86_64 Emulation)

> On older UTM installations, use the `copy-to-ram` install option, then run through the graphical installer.

After the install, run the following command:

```
sudo nixos-rebuild switch --flake github:heywoodlh/nixos-configs#nixos-utm --impure
```

</details>

### MacOS:

First, install Nix normally (not Determinate Nix):

```
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

To install a MacOS configuration, let's assume the `m4-macbook-air` output, do the following:

```
sudo rm -rf /etc/ssh/ssh_config # conflicts with a file in nix-darwin
sudo nix run "github:LNL7/nix-darwin#packages.aarch64-darwin.darwin-rebuild" -- switch --flake github:heywoodlh/nixos-configs#m4-macbook-air --impure
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
