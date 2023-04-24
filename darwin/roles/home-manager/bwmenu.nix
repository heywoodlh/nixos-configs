''
  #!/usr/bin/env bash
  # Choose extension for Bitwarden-cli
  PATH="/opt/homebrew/bin:/Users/heywoodlh/.nix-profile/bin:/etc/profiles/per-user/heywoodlh/bin:/run/current-system/sw/bin:$PATH"
  NAME="$(basename "$0")"
  VERSION="0.4.1"
  DEFAULT_CLEAR=15
  BW_HASH=
  
  
  # Options
  CLEAR=$DEFAULT_CLEAR # Clear password after N seconds (0 to disable)
  SHOW_PASSWORD=no # Show part of the password in the notification
  AUTO_LOCK=900 # 15 minutes, default for bitwarden apps
  
  # Holds the available items in memory
  ITEMS=
  
  # Specify what happens when pressing Enter on an item.
  ENTER_CMD=copy_password
  
  # Item type classification
  TYPE_LOGIN=1
  TYPE_NOTE=2
  TYPE_CARD=3
  TYPE_IDENTITY=4
  
  # Populated in parse_cli_arguments
  CHOOSE_OPTIONS=()
  DEDUP_MARK="(+)"
  
  check_keychain() {
    if ! security list-keychains | grep -iq bitwarden_choose
    then
      password=$(osascript -e 'Tell application "System Events" to display dialog "Enter Bitwarden Vault Password:" with hidden answer default answer ""' -e 'text returned of result')
      if ! echo -n $password | bw unlock --raw &>/dev/null
      then
        exit_error $? "Could not unlock vault" 
      fi
      security create-keychain -p "$password" bitwarden_choose
      security list-keychains -s $(security list-keychains | xargs) bitwarden_choose 
      security set-keychain-settings -lut "$AUTO_LOCK" bitwarden_choose
    fi
  }
  
  ask_password() {
    if [[ -z "$password" ]]
    then
      mpw=$(osascript -e 'Tell application "System Events" to display dialog "Enter Bitwarden Vault Password:" with hidden answer default answer ""' -e 'text returned of result') || exit $?
    else
      mpw="$password"
    fi
    echo -n "$mpw" | bw unlock --raw 2>/dev/null || exit_error $? "Could not unlock vault"
  }
  
  get_session_key() {
    if [ $AUTO_LOCK -eq 0 ]
    then
      if security list-keychains | grep -iq bitwarden_choose
      then
        lock_vault
      fi
      BW_HASH=$(ask_password)
    else
      if ! BW_HASH=$(security find-generic-password -a $USER -s bw_session -w bitwarden_choose 2>/dev/null)
      then
        BW_HASH=$(ask_password)
        security add-generic-password -a $USER -s bw_session -w "$BW_HASH" bitwarden_choose &>/dev/null
        [[ -z "$BW_HASH" ]] && exit_error 1 "Could not unlock vault"
      fi
    fi
  }
  
  # source the hash file to gain access to the BitWarden CLI
  # Pre fetch all the items
  load_items() {
    if ! ITEMS=$(bw list items --session "$BW_HASH" 2>/dev/null)
    then
      security delete-generic-password -a $USER -s bw_session bitwarden_choose
      exit_error $? "Could not load items. Deleting cookie."
    fi
  }
  
  exit_error() {
    local code="$1"
    local message="$2"
  
    osascript -e "tell app "System Events" to display dialog "$message""
    exit "$code"
  }
  
  choose_mode() {
    CHOOSE_MODE=$(printf "passwordntotpnnotesnusernamenresyncnlock" | choose -n6 $CHOOSE_OPTIONS)
  }
  
  show_password_items() {
    echo "$ITEMS" | jq -r '.[] | select( has( "login" ) ) | "(.name), ((.id))"'
  }
  
  show_username_items() {
    echo "$ITEMS" | jq -r '.[] | select(.login.username != null) | "(.name), ((.id))"'
  }
  
  show_totp_items() {
    echo "$ITEMS" | jq -r '.[] | select(.login.totp != null) | "(.name), ((.id))"'
  }
  
  show_note_items() {
    echo "$ITEMS" | jq -r '.[] | select(.notes != null) | "(.name), ((.id))"'
  }
  
  get_secret() {
    id=$1
    key=$2
    echo "$ITEMS" | jq -r ".[] | select( .id=="$id" ) | "$key""
  }
  
  notify-send() {
    message="$1"
    osascript -e "display notification "$message" with title "Bitwarden-Choose""
  }
  
  # re-sync the BitWarden items with the server
  sync_bitwarden() {
    notify-send "Syncing with Bitwarden"
    bw sync --session "$BW_HASH" &>/dev/null || exit_error 1 "Failed to sync bitwarden"
  
    load_items
    choose_menu
  }
  
  clipboard-clear() {
    echo -n "" | pbcopy 
  }
  
  # Lock the vault by purging the key used to store the session hash
  lock_vault() {
    security delete-generic-password -a $USER -s bw_session bitwarden_choose
  }
  
  choose_menu() {
    choose_mode
    SELECTION_KEY=".login.$CHOOSE_MODE"
  
    if [[ "$CHOOSE_MODE" == "password" ]]
    then
      SELECTION=$(show_password_items | choose $CHOOSE_OPTIONS)
    elif [[ "$CHOOSE_MODE" == "username" ]]
    then
      SELECTION=$(show_username_items | choose $CHOOSE_OPTIONS)
    elif [[ "$CHOOSE_MODE" == "totp" ]]
    then
      SELECTION=$(show_totp_items | choose $CHOOSE_OPTIONS) 
    elif [[ "$CHOOSE_MODE" == "notes" ]]
    then
      SELECTION=$(show_note_items | choose $CHOOSE_OPTIONS) 
      SELECTION_KEY=".notes" 
    elif [[ "$CHOOSE_MODE" == "resync" ]]
    then
      sync_bitwarden
    elif [[ "$CHOOSE_MODE" == "lock" ]]
    then
      lock_vault
    fi
  
    if [[ -n "$SELECTION" ]]
    then
      SELECTION_ID=$(echo "$SELECTION" |  awk -F "[()]" '{ for (i=2; i<NF; i+=2) print $i }')
      if [[ "$CHOOSE_MODE" != "totp" ]]
      then
        SECRET=$(get_secret "$SELECTION_ID" "$SELECTION_KEY")
      else
        SECRET=$(bw get totp "$SELECTION_ID" --session "$BW_HASH")
      fi
      if [[ "$SHOW_PASSWORD" == "yes" ]]
      then
        notify-send "$SECRET"
      else
        echo -n "$SECRET" | pbcopy
        notify-send "Copying secret to clipboard for $CLEAR seconds"
        if [[ $CLEAR -gt 0 ]]
        then
        sleep "$CLEAR"
          if [[ "$(pbpaste)" == "$SECRET" ]]; then
            clipboard-clear
          fi
        fi
      fi
    fi
  }
  
  
  
  parse_cli_arguments() {
    # Use GNU getopt to parse command line arguments
    if ! ARGUMENTS=$(getopt -o c:C --long auto-lock:,clear:,no-clear,show-password,state-path:,help,version -- "$@"); then
      exit_error 1 "Failed to parse command-line arguments"
    fi
    eval set -- "$ARGUMENTS"
  
    while true; do
      case "$1" in
        --help )
          cat <<-USAGE
  $NAME $VERSION
  
  Usage:
    $NAME [options] -- [choose options]
  
  Options:
    --help
        Show this help text and exit.
  
    --version
        Show version information and exit.
  
    --auto-lock <SECONDS>
        Automatically lock the Vault <SECONDS> seconds after last unlock.
        Use 0 to lock immediatly.
        Use -1 to disable.
        Default: 900 (15 minutes)
  
    -c <SECONDS>, --clear <SECONDS>, --clear=<SECONDS>
        Clear password from clipboard after this many seconds.
        Defaults: ''${DEFAULT_CLEAR} seconds.
  
    -C, --no-clear
        Don't automatically clear the password from the clipboard. This disables
        the default --clear option.
  
    --show-password
        Show the first 4 characters of the copied password in the notification.
  
  Examples:
    # Default options work well
    $NAME
  
  USAGE
          shift
          exit 0
          ;;
        --version )
          echo "$NAME $VERSION"
          shift
          exit 0
          ;;
        --auto-lock )
          AUTO_LOCK=$2
          shift 2
          ;; 
        -c | --clear )
          CLEAR="$2"
          shift 2
          ;;
        -C | --no-clear )
          CLEAR=0
          shift
          ;;
        --show-password )
          SHOW_PASSWORD=yes
          shift
          ;;
        -- )
          shift
          CHOOSE_OPTIONS=("$@")
          break
          ;;
        * )
          exit_error 1 "Unknown option $1"
      esac
    done
  }
  
  parse_cli_arguments "$@"
  
  check_keychain
  get_session_key
  load_items
  choose_menu
''
