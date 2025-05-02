{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.heywoodlh.home.docker-credential-1password;
  system = pkgs.system;
  docker-helper = pkgs.writeShellScriptBin "docker-credential-1password" ''
    #https://github.com/xebia/docker-credential-1password/
    # ENVIRONMENT
    # DOCKER_CREDENTIAL_1PASSWORD_VAULT - name of the 1password vault to use, default Docker
    export PATH="$HOME/bin:$PATH"

    if ! command -v op >/dev/null 2>&1
    then
      export PATH="${pkgs._1password-cli}/bin:$PATH"
    fi

    DOCKER_CREDENTIAL_1PASSWORD_VAULT="Docker"

    function get_docker_vault_ids  {
      op vault list --format json  | \
      ${pkgs.jq}/bin/jq --arg vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" -r 'map(select(.name == $vault) | .id)|.[]'
    }

    function get_vault_id  {
      result=($(get_docker_vault_ids))

      case ''${#result[@]} in
       1)
        echo $result;;
       0)
        return 1;;
       *)
        echo "ERROR: multiple '$DOCKER_CREDENTIAL_1PASSWORD_VAULT' vaults found in 1Password" >&2
        return 2;;
      esac
    }

    function get {
      registry=$(</dev/stdin)
      vault_id=$(get_vault_id)
      [[ -z $vault_id ]] && return 0
      credentials=$(op item get "$registry" \
                    --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" --format json 2>/dev/null)

      [[ -z $credentials ]] && return 1

      ${pkgs.jq}/bin/jq --arg registry $registry '{
        ServerURL: $registry,
        Username: (.fields|map(select(.id == "username")|.value)|.[0]),
        Secret: (.fields|map(select(.id == "credential")|.value)|.[0])
             }' <<< "$credentials"
    }

    function erase {
      registry=$(</dev/stdin)
      vault_id=$(get_vault_id)
      [[ -z $vault_id ]] && return 0

      item=$(op item get "$registry" --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" --format json 2> /dev/null)
      if [[ -n $item ]]; then
        op item delete $(${pkgs.jq}/bin/jq -r .id <<< $item) --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" > /dev/null
      fi
    }

    function list {
      vault_id=$(get_vault_id);exit_code=$?
      if [[ -z $vault_id ]] && [[ $exit_code -eq 1 ]]; then
        echo '{}'
        return
      elif [[ -z $vault_id ]]; then
        return 1
      fi
      [[ -z $vault_id ]] && return 0
      op item  list --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" --format json  | \
        ${pkgs.jq}/bin/jq -r 'map(.id)|.[]' | \
      while read id; do
        op item get $id --format json | \
        ${pkgs.jq}/bin/jq '{(.title | sub("^";"https://")): (.fields|map(select(.id == "username")|.value)|.[0]) }'
      done | ${pkgs.jq}/bin/jq -rs add | ${pkgs.jq}/bin/jq -r 'if(.!=null) then . else {} end'
    }

    function store {
      body=$(</dev/stdin)
      url=$(${pkgs.jq}/bin/jq -r '.ServerURL' <<< $body)
      username=$(${pkgs.jq}/bin/jq -r '.Username' <<< $body)
      credential=$(${pkgs.jq}/bin/jq -r '.Secret' <<< $body)

      vault_id=$(get_vault_id)
      exit_code=$?
      if [[ -z $vault_id ]] && [[ $exit_code == 1 ]]; then
        vault_id=$(op vault create --format json "$DOCKER_CREDENTIAL_1PASSWORD_VAULT"  </dev/null | ${pkgs.jq}/bin/jq -r .ID)
        [[ -z $vault_id ]] && echo "ERROR: failed to create Vault '$DOCKER_CREDENTIAL_1PASSWORD_VAULT'">&2  && exit 1
      elif [[ -z $vault_id ]]; then
        exit 1
      fi

      items=($(op item list --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" --format json | \
              ${pkgs.jq}/bin/jq -r --arg title $url 'map(select(.title == $title)|.id)|.[]'))
      if [[ ''${#items[@]} -eq 0 ]]; then
        op item create --format json \
          --title "$url" --category "API Credential" \
          --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" -- \
          "username=$username" \
                      "credential=$credential" \
                      "valid from=$(date +%s)" \
                      "expires=2147483647" \
                      </dev/null >/dev/null
      else
        op item edit --format json \
          "''${items[0]}" \
          --vault "$DOCKER_CREDENTIAL_1PASSWORD_VAULT" -- \
          "username=$username" \
                      "credential=$credential" \
                      "valid from=$(date +%s)" \
                      "expires=2147483647" \
                      </dev/null >/dev/null
      fi
    }

    function usage {
      echo "Usage: docker-credential-1password [get|list|store|erase]" >&2
      echo "$@" >&2
      exit 1
    }

    function main {
      if ! which ${pkgs.jq}/bin/jq >/dev/null 2>&1 ; then
          usage "missing ${pkgs.jq}/bin/jq on PATH"
      fi
      if ! which op >/dev/null 2>&1 ; then
          usage "missing 1password CLI (op) on PATH"
      fi

      case $1 in
          list|get|store|erase)
        eval $1;;
          *)
          usage "unknown option $1"
      esac
    }

    main "$@"

  '';
in {
  options = {
    heywoodlh.home.docker-credential-1password = {
      enable = mkOption {
        default = false;
        description = ''
          Install 1password credential helper and configure docker client to use it.
        '';
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      docker-helper
    ];
  };
}
