FROM ubuntu:22.04
LABEL maintainer=heywoodlh

ENV DEBIAN_FRONTEND=noninteractive
ENV DONT_PROMPT_WSL_INSTALL=1

# Install dependencies
RUN apt-get update && apt-get install -y curl xz-utils git gnome-shell dbus screen ca-certificates openssh-client --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Add heywoodlh user
RUN adduser --disabled-password --gecos "" --uid 1000 heywoodlh \
    && chown -R heywoodlh /home/heywoodlh \
    && mkdir -m 0755 /nix && chown heywoodlh /nix

COPY docker/session.conf /etc/dbus-1/session.conf
# Run Nix configurations
USER heywoodlh
# Install Nix
COPY . /home/heywoodlh/opt/nixos-configs
ENV USER=heywoodlh

# Start dummy dbus session for nix build
# Then, run nix build as heywoodlh with su
USER root
RUN screen -dmS dbus-daemon dbus-daemon --config-file=/etc/dbus-1/session.conf --print-address \
    && su -c "curl -L https://nixos.org/nix/install | bash -s -- --no-daemon --yes" heywoodlh \
    && su -c "/home/heywoodlh/.nix-profile/bin/nix run --extra-experimental-features 'nix-command flakes' /home/heywoodlh/opt/nixos-configs#homeConfigurations.heywoodlh.activationPackage --impure" heywoodlh \
    && screen -S dbus-daemon -X quit

# Change shell to zsh
RUN chsh -s /home/heywoodlh/.nix-profile/bin/zsh heywoodlh

USER heywoodlh
RUN mkdir -p /home/heywoodlh/tmp \
    && mkdir -p -m 700 /home/heywoodlh/.ssh

WORKDIR /home/heywoodlh
ENTRYPOINT ["/home/heywoodlh/.nix-profile/bin/zsh"]
