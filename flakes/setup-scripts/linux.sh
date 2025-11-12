#!/usr/bin/env bash
# Script to setup bare-minimum Linux env

if ! uname | grep -iq 'Linux'
then
    echo "This script must be run on a Linux system"
    exit 1
fi

print-usage () {
    printf "\nUsage: %s [workstation|server|files-only|debs] [--ansible --home-manager]\n" "$0"
    exit 0
}

[[ $# -eq 0 ]] && print-usage

if command -v curl &> /dev/null
then
    download_file () {
        url="$1"
        dest="$2"

        [[ ! -e "${dest}" ]] && echo "Downloading: $url => $dest" && curl --silent -L "${url}" -o "${dest}"
    }
else
    echo "Please install curl and re-run this script"
    exit 1
fi

# Flakes variable for all things to reference
flakes="vim tmux git"

# Exit if $1 doesn't exist or is not workstation/server/files-only
system="$1"
[[ "${system}" != "workstation" && "${system}" != "server" && "${system}" != "files-only" && "${system}" != "debs" ]] && print-usage

if [[ "${system}" == "files-only" ]]
then
    # Install appimages only and place them in $HOME/bin
    mkdir -p $HOME/bin
    # Download flakes
    for flake in $flakes
    do
        download_file "https://github.com/heywoodlh/nixos-configs/releases/download/appimages/${flake}-$(arch).appimage" "$HOME/bin/${flake}" \
        && chmod +x "${HOME}/bin/${flake}" \
        && echo "${HOME}/bin/${flake}" installed
    done

    if ! grep -q 'heywoodlh-PATH' "${HOME}/.profile" &>/dev/null
    then
        echo "Setting up PATH in ${HOME}/.profile"
        printf "#heywoodlh-PATH\nexport PATH=\"$HOME/bin:$PATH\"" >> ${HOME}/.profile
    fi
elif [[ "${system}" == "debs" ]]
then
    install-deb() {
        url="$1"
        curl -L "${url}" --clobber -o /tmp/heywoodlh-installer.deb
        # if not root, add sudo
        if [[ $EUID -ne 0 ]]
        then
            sudo dpkg -i /tmp/heywoodlh-installer.deb
        else
            dpkg -i /tmp/heywoodlh-installer.deb
        fi
        rm /tmp/heywoodlh-installer.deb
    }
    grep -qi debian /etc/os-release || { echo "Option debs only supported on debian-derivatives. Exiting."; exit 1; }
    [[ "$(id -u)" != 0 ]] && { command -v sudo &>/dev/null || { echo "Please install sudo and re-run this script."; exit 1; } }
    [[ "$(arch)" == "x86_64" ]] || { echo "Option debs only support on x86_64. Exiting."; exit 1; }
    for deb in flakes
    do
        install-deb "https://github.com/heywoodlh/nixos-configs/releases/download/packages/${deb}-amd64.deb"
    done
    # include 1password deb
    install-deb https://github.com/heywoodlh/nixos-configs/releases/download/packages/1password-amd64.deb
else
    # If --ansible provided, set ansible=true
    echo "$@" | grep -q '\-\-ansible' && ansible=true
    # If --home-manager provided, set home-manager=true
    echo "$@" | grep -q '\-\-home-manager' && home_manager=true

    # Install Nix
    if grep -q 'Alpine Linux' /etc/os-release
    then
        # Enable the community repository
        sudo sed -i 's/#\(.*\/community\)/\1/' /etc/apk/repositories
        # Install Nix package
        sudo apk add --no-cache nix shadow
        # Add user to nix group
        sudo usermod -aG nix $USER
        # Configure nix
        grep flakes /etc/nix/nix.conf || printf "extra-experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
        # Enable nix-daemon
        sudo rc-update add nix-daemon
        sudo rc-service nix-daemon restart
    elif grep -q 'Arch Linux' /etc/os-release
    then
        sudo pacman -Sy --noconfirm nix
        sudo systemctl enable --now nix-daemon.service
        sudo usermod -aG nix-users $USER
    else
        if [ ! -d /nix/var/nix ]
        then
            echo "Installing Nix"
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
            sudo chown -R "$EUID" /nix
        fi
    fi

    # Source nix-daemon.sh
    [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ] && . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

    install-nix-package () {
        package_bin="$1"
        package_source="$2"
        unfree="$3"

        exists=false
        ls -l "$HOME/.nix-profile/bin/${package_bin}" &>/dev/null && exists=true

        if [[ "${exists}" == "false" ]]
        then
            if [[ -n "${unfree}" ]]
            then
                echo "Installing unfree package ${package_source}"
                NIXPKGS_ALLOW_UNFREE=1 nix profile install "${package_source}" --impure
            else
                echo "Installing package ${package_source}"
                nix profile install "${package_source}" --no-write-lock-file
            fi
        else
            echo "Package ${package_source} already exists"
        fi
    }


    if [[ "${home_manager}" != "true" ]]
    then
        echo "Installing standalone packages"
        # Install flakes
        for flake in $flakes
        do
            install-nix-package "${flake}" "github:heywoodlh/nixos-configs?dir=flakes#${flake}"
        done

        # Configure Desktop
        if [[ "${system}" == "workstation" ]]
        then
            echo "Configuring GNOME"
            nix run "github:heywoodlh/nixos-configs?dir=flakes/gnome"
            echo "Configuring Firefox"
            nix run "github:heywoodlh/nixos-configs?dir=flakes/firefox#firefox-setup"
        fi

        # Install 1password
        install-nix-package "op" "github:heywoodlh/nixos-configs?dir=flakes/1password" "unfree"
        [[ "${system}" == "workstation" ]] && install-nix-package "1password" "nixpkgs#_1password-gui" "unfree"
        [[ "${system}" == "workstation" ]] && mkdir -p ~/.config/autostart && ln -s ~/.nix-profile/share/applications/1password.desktop ~/.config/autostart/1password.desktop &>/dev/null
        [[ "${system}" == "workstation" ]] && nix run "github:heywoodlh/nixos-configs?dir=flakes/1password#op-desktop-setup" && chmod u+w ~/.config/1Password/settings/settings.json

        # Install Lima for Docker
        install-nix-package "lima" "nixpkgs#lima"
        install-nix-package "docker" "nixpkgs#docker-client"
    else
        if [[ $EUID -eq 0 ]]
        then
            echo "Script was invoked as root, skipping home-manager"
            exit 1
        else
            # If WSL
            if which wsl.exe &>/dev/null
            then
                echo "WSL detected, starting dconf manually"
                export $(dbus-launch)
            fi

            if [[ "${system}" == "workstation" ]]
            then
                echo "Installing home-manager desktop configuration"
                nix run "github:heywoodlh/nixos-configs/$(nix run nixpkgs#git -- ls-remote https://github.com/heywoodlh/nixos-configs | head -1 | awk '{print $1}')#homeConfigurations.heywoodlh.activationPackage" --impure --no-write-lock-file
            fi

            if [[ ${system} == "server" ]]
            then
                echo "Installing home-manager server configuration"
                nix run "github:heywoodlh/nixos-configs/$(nix run nixpkgs#git -- ls-remote https://github.com/heywoodlh/nixos-configs | head -1 | awk '{print $1}')#homeConfigurations.heywoodlh-server.activationPackage" --impure --no-write-lock-file
            fi
        fi
    fi

    # Run ansible playbooks
    if [[ "${ansible}" == "true" ]]
    then
        echo "Running ansible playbooks"
        nix run "github:heywoodlh/nixos-configs/$(git ls-remote https://github.com/heywoodlh/nixos-configs | head -1 | awk '{print $1}')?dir=flakes/ansible#${system}"
    fi

    # If WSL
    if which wsl.exe &>/dev/null
    then
        echo "WSL detected, adding WSL configuration"
        mkdir -p $HOME/bin
cat > $HOME/bin/windows-firefox-setup << EOL
#!/usr/bin/env bash
drive="\$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null | cut -d':' -f1 | tr [:upper:] [:lower:])"
firefox_profile="/mnt/\${drive}/\$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null | sed 's/\\\/\//g' | cut -d':' -f2)/AppData/Roaming/Mozilla/Firefox/Profiles"
nix --extra-experimental-features "flakes nix-command" run "github:heywoodlh/nixos-configs?dir=flakes/firefox#firefox-setup" -- "\${firefox_profile}"
EOL
        chmod +x "$HOME/bin/windows-firefox-setup"
    fi

    # Symlink vim if it doesn't exist
    [[ ! -e /usr/local/bin/vim ]] && [[ -e "${HOME}/.nix-profile/bin/vim" ]] && sudo ln -s "${HOME}/.nix-profile/bin/vim" /usr/local/bin/vim &>/dev/null || true
fi
