# requirements

## comments

Self-explanatory code should have absolutely no comments.

Comments should be limited to one line. If multi-line comments are required, shorten them as much as possible.

# nixos-configs layout

- `base`: things shared between nix-darwin and NixOS.
- `darwin`: nix-darwin specific configuration.
  - `darwin/modules`: custom nix-darwin modules.
  - `darwin/roles`: nix configurations that just get imported.
- `nixos`: NixOS specific configuration.
  - `nixos/modules`: custom NixOS modules.
  - `nixos/hosts`: host-specific configurations.
  - `nixos/roles`: nix configurations that get imported.
- `home`: home-manager configuration.
  - `home/modules`: custom home-manager modules.
  - `home/base.nix`: applied to all machines.
  - `home/desktop.nix`: applied to all desktop workstations.
  - `home/darwin.nix`: applied to macOS.
  - `home/linux.nix`: applied to Linux.
  - `home/linux`: more things applied to Linux.
- `flakes/kube`: Kubernetes deployment manifests. See `flakes/kube/AGENTS.md`.

## Custom modules

All custom options live under the `heywoodlh` option namespace:

- `heywoodlh.defaults`: shared user/hostname defaults. Set by the flake-level
  configuration builders in `flake.nix` (`nixosConfig`, `darwinConfig`), not
  by hosts.
- `heywoodlh.nixos.*`: NixOS-only options, defined by modules in
  `nixos/modules`.
- `heywoodlh.darwin.*`: nix-darwin-only options, defined by modules in
  `darwin/modules`.
- `heywoodlh.home.*`: home-manager options, defined by modules in
  `home/modules`.

### How modules get composed

Everything is wired in the root `flake.nix`:

- `nixosConfigWith` builds every NixOS host (`nixosConfig` is the common
  entrypoint). It always imports `nixosModules.heywoodlh` (which aggregates
  `nixos/modules`), home-manager, and a base set of options, then appends role
  modules based on the `machineType` argument: `server`, `workstation`,
  `laptop`, `vm`, `lima`, `console`, `tv`. Host-specific configuration is
  passed as `extraConf` in the host definitions under
  `nixosConfigurations.<hostname>`.
- `darwinConfig` builds every macOS host the same way: it always imports
  `darwinModules.heywoodlh.darwin` (aggregating `darwin/modules`) plus
  `darwin/roles/*`, with host-specific configuration as `extraConf` in
  `darwinConfigurations.<hostname>`.
- Home-manager configuration is applied per user with
  `home-manager.users.<user>` inside the host's `extraConf`. Common
  home-manager configuration comes from `homeModules.heywoodlh.home`, which is
  attached as `home-manager.sharedModules` on every NixOS host (and imported
  directly on darwin hosts). `homeModules.heywoodlh.home` aggregates
  `platformHomeModules`: `commonHomeModules` plus `linuxHomeModules` or
  `macosHomeModules` depending on platform. Servers additionally get
  `home/linux/no-desktop.nix` shared in.

### Adding a new option or module

- Fleet-wide NixOS behavior goes into a small module in `nixos/modules` and is
  imported from the appropriate `machineType` branch of `nixosConfigWith` (or
  from `nixos/modules/defaults.nix` for every host). Do not duplicate fleet
  behavior across host files.
- Fleet-wide home-manager behavior goes into `home/modules` and is picked up
  automatically through `homeModules.heywoodlh.home`.
- Host-specific settings belong in the host's `extraConf` in `flake.nix` (or
  its file under `nixos/hosts`), not in shared modules.
- Every module's options must be defined with typed `mkOption`s under the
  correct `heywoodlh.*` subtree; modules must be inert (no config) when their
  `enable` is false.
- New files must be `git add`ed before any flake evaluation: Git-based flake
  source excludes untracked paths.

### Option documentation

- `docs/options.md` is generated from all custom options via the `.#docs`
  flake output (`nixosOptionsDoc` over `homeModules.docs` +
  `nixosModules.docs` + `darwinModules.heywoodlh.darwin`).
- The `gen-docs` lefthook pre-commit hook rebuilds it and stages it on every
  commit. If it stages unrelated churn (e.g. store-path comment changes),
  restore `docs/options.md` from the base branch and amend with
  `--no-verify`.

## Building

- NixOS configurations are usually built with a helper script called
  `nixos-switch`, which runs
  `sudo nixos-rebuild switch --flake ~/opt/nixos-configs#$(hostname)`.
- Agents: do not build or cache NixOS closures locally. Validate with
  `nix-instantiate --parse`, `nix eval`, and `kubectl create
  --dry-run=client` (for `flakes/kube` manifests) only; GitHub Actions builds
  and caches on pull requests.

## Flake inputs

- When adding or updating flake inputs, scan `flake.lock` for duplicate
  inputs with `grep _2 flake.lock` (duplicates show up with a `_2`
  suffix). Add appropriate `follows` (e.g. `inputs.nixpkgs.follows =
  "nixpkgs"`) to deduplicate them. The `check-dupe-inputs` lefthook
  pre-commit hook enforces this.
- Prefer `nixpkgs-edge` for bleeding-edge packages rather than bumping the
  primary `nixpkgs` input; edge updates are automated weekly by CI.

# Code

Do not add multi-line comments ever. Code that is self-explanatory should not have comments.
