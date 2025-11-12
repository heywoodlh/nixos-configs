# Ubuntu target
FROM docker.io/heywoodlh/systemd:ubuntu AS ubuntu-base
COPY ./linux.sh /linux.sh
COPY docker/server.sh /server.sh
COPY docker/desktop.sh /desktop.sh
COPY docker/debs.sh /debs.sh

RUN apt update && apt install -y sudo git curl \
    && useradd -ms /bin/bash heywoodlh

COPY docker/sudo-heywoodlh /etc/sudoers.d/heywoodlh

# Ubuntu server
FROM ubuntu-base AS ubuntu-server
CMD [ "/server.sh"]

# Ubuntu desktop
FROM ubuntu-base AS ubuntu-desktop
CMD [ "/desktop.sh"]

# Ubuntu debs only
FROM ubuntu-base AS ubuntu-debs
CMD [ "/debs.sh"]

# Debian target
FROM docker.io/heywoodlh/systemd:debian AS debian-base
COPY ./linux.sh /linux.sh
COPY docker/server.sh /server.sh
COPY docker/desktop.sh /desktop.sh
COPY docker/debs.sh /debs.sh

RUN apt update && apt install -y sudo git curl \
    && useradd -ms /bin/bash heywoodlh

COPY docker/sudo-heywoodlh /etc/sudoers.d/heywoodlh

# Debian server
FROM debian-base AS debian-server
CMD [ "/server.sh"]

# Debian desktop
FROM debian-base AS debian-desktop
CMD [ "/desktop.sh"]

# Debian debs only
FROM debian-base AS debian-debs
CMD [ "/debs.sh"]

# Alpine target
FROM docker.io/heywoodlh/openrc AS alpine-base
COPY ./linux.sh /linux.sh
COPY docker/server.sh /server.sh
COPY docker/desktop.sh /desktop.sh

RUN apk add bash sudo git curl \
    && addgroup -S heywoodlh && adduser -S heywoodlh -G heywoodlh

COPY docker/sudo-heywoodlh /etc/sudoers.d/heywoodlh

# Alpine server
FROM alpine-base AS alpine-server
CMD [ "/server.sh"]

# Alpine desktop
FROM alpine-base AS alpine-desktop
CMD [ "/desktop.sh"]

# Arch Linux target
FROM docker.io/heywoodlh/systemd:archlinux AS archlinux-base
COPY ./linux.sh /linux.sh
COPY docker/server.sh /server.sh
COPY docker/desktop.sh /desktop.sh

RUN pacman -Sy --noconfirm sudo git curl

COPY docker/sudo-heywoodlh /etc/sudoers.d/heywoodlh

# Arch Linux server
FROM archlinux-base AS archlinux-server
CMD [ "/server.sh"]

# Arch Linux desktop
FROM archlinux-base AS archlinux-desktop
CMD [ "/desktop.sh"]
