#!/usr/bin/env bash

# Check if $1 is set (it should be a username)
if [ -z "$1" ]; then
    echo "Usage: ./darwin-noninteractive.sh <username>"
    exit 1
else
    username="$1"
fi

# Check if current user is root
if [ "$(id -u)" != "0" ]; then
    echo "this script must be run as root" 1>&2
    exit 0
fi

# Check if device is MacOS or not
if uname -a | grep -iq darwin
then
    echo 'host is running macos'
else
    echo 'host is not running macos, exiting.'
    exit 0
fi

# Check if M1/M2 or Intel Mac
if [[ $(arch) == 'arm64' ]]
then
    # Actions for M1/M2 Macs
    homebrew_bin_path='/opt/homebrew/bin/brew'
    homebrew_dir='/opt/homebrew'
else
    # Actions for non-M1/M2 Macs
    homebrew_bin_path='/usr/local/bin/brew'
    homebrew_dir='/usr/local'
fi

# Install Nix noninteractively if not installed
if ! test -e /etc/nix/nix.conf > /dev/null
then
    echo 'nix not installed, installing now'
    bash <(curl -L https://nixos.org/nix/install) --yes --daemon
fi

# Check if $username does not exist, if not, create it
if ! dscl . list /Users | grep -q "${username}"
then
    echo "user ${username} does not exist, creating now"
    dscl . -create /Users/${username}
    dscl . create /Users/${username} UserShell /bin/bash
    dscl . create /Users/${username} RealName "${username}"
    dscl . create /Users/${username} UniqueID 1000
    dscl . create /Users/${username} PrimaryGroupID 80
    dscl . create /Users/${username} NFSHomeDirectory /Users/${username}
    createhomedir -c -u ${username} > /dev/null
else
    echo "user ${username} already exists"
fi

# Allow user to install applications without requiring a password
if ! grep -q "user=${username}" /etc/pam.d/authorization
then
    echo "enabling user to install applications in /Applications without password"
    echo "auth sufficient pam_permit.so user=${username}" | tee -a /etc/pam.d/authorization
fi

# Allow user to run sudo commands without password
if ! grep -q "${username}" /etc/sudoers
then
    echo "enabling user to run sudo commands without password"
    echo "${username} ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers
fi

# Install Homebrew manually if not installed
if ! test -e ${homebrew_bin_path} > /dev/null
then
    echo 'homebrew not installed, installing now'
    mkdir -p ${homebrew_dir} && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C ${homebrew_dir}
fi
chown -R ${username}:staff ${homebrew_dir}

# Create /tmp/shellenv.sh file
${homebrew_bin_path} shellenv > /tmp/shellenv.sh

# Install xcode command-line-tools
echo "checking if xcode cli tools are installed"
# Only run if the tools are not installed yet
xcode-select -p &> /dev/null
if [ $? -ne 0 ]; then
  echo "xcode cli tools not found, installing now"
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l |
    grep "\*.*Command Line" |
    tail -n 1 | sed 's/^[^C]* //')
    echo "Prod: ${PROD}"
  softwareupdate -i "$PROD" --verbose;
else
  echo "xcode cli tools are installed"
fi

# Update /etc/synthetic.conf
if ! grep -q run /etc/synthetic.conf
then
    echo 'updating synthetic.conf' to work with nix-darwin
    printf 'run\tprivate/var/run\n' | sudo tee -a /etc/synthetic.conf
    /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
fi

# Setup symlinks for variables not passing through
mkdir -p /Users/${username}/.nix-profile
ln -s /Users/${username}/.nix-profile /var/root/.nix-profile
ln -s /Users/${username}/.nix-channels /var/root/.nix-channels
ln -s /Users/${username}/.nix-defexpr /var/root/.nix-defexpr

# Run the remaining commands as $username
sudo -i -u ${username} bash << EOF
    export HOME=/Users/${username}
    cd /Users/${username}
    # If homebrew is installed, make sure that shellenv is evaluated
    if test -e ${homebrew_bin_path} > /dev/null
    then
        echo 'evaluating homebrew shellenv'
        source /tmp/shellenv.sh
    else
        echo 'homebrew not installed -- fix this and then re-run this script -- exiting'
        exit 1
    fi

    # Source /etc/bashrc (to add nix to PATH)
    source /etc/bashrc


    # Install nix-darwin
    cd /tmp
    /nix/var/nix/profiles/default/bin/nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
    ./result/bin/darwin-installer

    # Install git with brew
    brew install git

    # Clone heywoodlh/nixos-configs repo
    mkdir -p /Users/${username}/opt
    git clone https://github.com/heywoodlh/nixos-configs /Users/${username}/opt/nixos-configs

    # Remove default nix-darwin /Users/${username}/.nixpkgs, replaced with nixos-configs/darwin
    rm -rf /Users/${username}/.nixpkgs
    ln -s /Users/${username}/opt/nixos-configs/darwin /Users/${username}/.nixpkgs

    # Install nix-darwin config
    /run/current-system/sw/bin/darwin-rebuild switch -I "darwin-config=/Users/${username}/opt/nixos-configs/darwin/darwin-configuration.nix"
EOF
