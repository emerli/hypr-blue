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
    firewalld \
    thunar \
    mousepad \
    fontawesome-6-brands-fonts \
    fontawesome-6-free-fonts \
    jetbrains-mono-fonts-all
