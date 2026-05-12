{ pkgs }:
pkgs.writeShellScriptBin "tangled-sync.sh" ''
  # Helper to point git repo at tangled.org (primary) and GitHub (mirror)
  # Assumes directory name is repo name
  # Also assumes repo has been created with same name on tangled.org
  dir="$(git rev-parse --show-toplevel)"
  name="$(basename $dir)"
  if git -C "$dir" remote -v &>/dev/null
  then
    target="git@tangled.org:heywoodlh.io/$name"
    src="git@github.com:heywoodlh/$name"

    # If primary origin is not yet tangled.org, set it
    if ! git -C "$dir" remote -v | grep -E '^origin' | grep '(fetch)' | grep -q tangled.org
    then
      git -C "$dir" remote remove origin && git -C "$dir" remote add origin "$target" && echo "Set primary origin: [fetch] $src -> $target"
    fi

    # Re-add GitHub push to origin
    if ! git -C "$dir" remote -v | grep -E '^origin' | grep -q "$src"
    then
      git -C "$dir" remote set-url --add --push origin &>/dev/null $src && echo "Added origin (for mirroring): [push] -> $src"
    fi

    # Re-add Tangled push to origin
    if ! git -C "$dir" remote -v | grep -E '^origin' | grep push | grep -q "$target"
    then
      git -C "$dir" remote set-url --add --push origin $target &>/dev/null && echo "Added origin: [push] -> $target"
    fi
  else
    echo "$dir is not a git repository"
  fi
''
