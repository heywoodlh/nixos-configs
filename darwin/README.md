### My nix-darwin config


Setup:

1. [Install nix]()

2. [Install nix-darwin](https://github.com/LnL7/nix-darwin#install)

3. Remove the default `~/.nixpkgs` and replace with this repo:

```bash
rm -rf ~/.nixpkgs
mkdir -p ~/opt &&\
	git clone https://github.com/heywoodlh/nixos-configs ~/opt/nixos-configs
	ln -s ~/opt/nixos-configs/darwin ~/.nixpkgs
```

4. Install:

```bash
darwin-rebuild switch -I "darwin-config=$HOME/opt/nixos-configs/darwin/darwin-configuration.nix"
```
