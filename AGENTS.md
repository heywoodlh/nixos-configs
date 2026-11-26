# requirements

## comments

Self-explanatory code should have absolutely no comments.

Comments should be limited to one line. If multi-line comments are required, shorten them as much as possible.

# nixos-configs layout

- `base`: things shared between nix-darwin and NixOS.
- `darwin`: nix-darwin specific configuration.
  - `darwin/hosts`: one file per macOS host. Import it from `flake.nix` and
    keep everything host-specific in it.
  - `darwin/modules`: custom nix-darwin modules.
  - `darwin/roles`: nix configurations that just get imported.
- `nixos`: NixOS specific configuration.
  - `nixos/hosts`: one file per NixOS host, including its
    `hardware-configuration.nix` import.
  - `nixos/machine-types`: role modules selected per host
    (`server`, `workstation`, `laptop`, `vm`, `lima`, `console`, `tv`).
  - `nixos/modules`: custom NixOS modules.
  - `nixos/roles`: nix configurations that get imported.
- `home`: home-manager configuration.
  - `home/hosts`: one file per standalone home-manager target.
  - `home/modules`: custom home-manager modules.
  - `home/base.nix`: applied to all machines.
  - `home/desktop.nix`: applied to all desktop workstations.
  - `home/darwin.nix`: applied to macOS.
  - `home/linux.nix`: applied to Linux.
  - `home/linux`: more things applied to Linux.
- `pkgs`: packages that used to live in nested flakes. `pkgs/default.nix`
  assembles the `myPkgs` package set consumed by modules.
- `kubernetes`: Kubernetes templates and deployment variables. CI renders the
  manifests and applies them directly; nothing is committed to `main`. See
  `kubernetes/AGENTS.md`.

## `flake.nix` policy

`flake.nix` must contain as little code as possible. Do not add host-specific
configuration to it. Changes belong in `flake.nix` only when they impact
multiple builds (for example the custom NixOS, Darwin, and Home-Manager module
lists) or are unavoidable flake wiring.

- Every NixOS host is one entry in the `nixosConfigurations` registry. The
  entry names `system` and, when not a workstation, `type`; the builder
  imports `nixos/hosts/<name>.nix`, which owns everything else for that host.
- Every macOS host is one entry in `darwinConfigurations`; the builder imports
  `darwin/hosts/<name>.nix`.
- Every standalone home-manager target is one entry in
  `homeConfigurations`; the builder imports `home/hosts/<name>.nix`. It lives
  under `packages.<system>` so each target builds for its own architecture;
  `.#homeConfigurations.<name>` still resolves through the package fallback.

## Custom modules

All custom options live under the `heywoodlh` option namespace:

- `heywoodlh.defaults`: shared user/hostname defaults. Set by the flake-level
  configuration builders in `flake.nix`, not by hosts.
- `heywoodlh.nixos.*`: NixOS-only options, defined by modules in
  `nixos/modules`.
- `heywoodlh.darwin.*`: nix-darwin-only options, defined by modules in
  `darwin/modules`.
- `heywoodlh.home.*`: home-manager options, defined by modules in
  `home/modules`.

### How modules get composed

Everything is wired in the root `flake.nix`:

- `mkNixos` builds a NixOS host from `nixos/hosts/<name>.nix` plus
  `nixosModules.heywoodlh`, home-manager, the selected
  `nixos/machine-types/<type>.nix` module, and a small shared defaults block.
- `mkDarwin` builds a macOS host from `darwin/hosts/<name>.nix` plus
  `darwinModules.heywoodlh.darwin` and the shared `darwin/roles/*` modules.
- `mkHome system name` builds a standalone home-manager target from
  `home/hosts/<name>.nix` plus `homeModules.heywoodlh.home`. That module
  imports the common, Linux, or macOS module sets based on the target
  platform, so the same `heywoodlh.home` output works everywhere.
- Servers additionally get `home/linux/no-desktop.nix` shared in through
  `nixos/machine-types/server.nix`.

### Adding a new option or module

- Fleet-wide NixOS behavior goes into a small module in `nixos/modules` and is
  imported from the appropriate `nixos/machine-types/<type>.nix` module (or
  from `nixos/modules/defaults.nix` for every host). Do not duplicate fleet
  behavior across host files.
- Fleet-wide home-manager behavior goes into `home/modules` and is picked up
  automatically through the home module aggregations.
- Host-specific settings belong in the host file under `nixos/hosts`,
  `darwin/hosts`, or `home/hosts`, not in shared modules and not in
  `flake.nix`.
- Every module's options must be defined with typed `mkOption`s under the
  correct `heywoodlh.*` subtree; modules must be inert (no config) when their
  `enable` is false.
- New files must be `git add`ed before any flake evaluation: Git-based flake
  source excludes untracked paths.

### Option documentation

- `docs/options.md` is generated from all custom options via the `.#docs`
  flake output.
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
  --dry-run=client` (for `kubernetes` manifests) only; GitHub Actions builds
  and caches on pull requests.

## Checks

- `lint.yml` runs Alejandra, deadnix, shellcheck, actionlint, and yamllint.
- `security.yml` runs gitleaks and zizmor.
- The same fast checks run in lefthook before each local commit.

## Flake inputs

- When adding or updating flake inputs, scan `flake.lock` for duplicate
  inputs with `grep _2 flake.lock` (duplicates show up with a `_2`
  suffix). Add appropriate `follows` (e.g. `inputs.nixpkgs.follows =
  "nixpkgs"`) to deduplicate them. The `check-dupe-inputs` lefthook
  pre-commit hook enforces this.
- Prefer `nixpkgs-edge` for bleeding-edge packages rather than bumping the
  primary `nixpkgs` input; edge updates are automated weekly by CI.
- There are no nested flakes under `pkgs/`; shared packages live there and are
  exposed through the root flake's `packages` output. The only nested flake is
  `kubernetes/flake.nix`, used by `kubernetes/render.sh` to render manifests.

# Code

Do not add multi-line comments ever. Code that is self-explanatory should not have comments.
