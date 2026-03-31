#!/bin/bash
set -ouex pipefail

dnf5 install -y \
    git \
    curl \
    wget \
    nano \
    neovim \
    htop \
    zip \
    unzip \
    p7zip \
    p7zip-plugins \
    rsync \
    meld \
    vlc \
    libreoffice \
    openconnect \
    NetworkManager-openconnect \
    flatpak \
    plocate \
    firewalld


#!/bin/bash
set -ouex pipefail

NERD_FONT_VERSION="3.3.0"

curl -fLo /tmp/JetBrainsMono.tar.xz \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/JetBrainsMono.tar.xz

mkdir -p /usr/share/fonts/JetBrainsMonoNF
tar -xf /tmp/JetBrainsMono.tar.xz -C /usr/share/fonts/JetBrainsMonoNF
rm /tmp/JetBrainsMono.tar.xz
fc-cache -fv
