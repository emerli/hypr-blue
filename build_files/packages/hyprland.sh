#!/bin/bash
set -ouex pipefail

dnf5 install -y \
    hyprland \
    hyprland-guiutils \
    hyprland-qt-support \
    hyprpaper \
    hyprlock \
    hypridle \
    xdg-desktop-portal-hyprland \
    wl-clipboard \
    mako \
    brightnessctl \
    playerctl \
    pavucontrol \
    network-manager-applet \
    blueman \
    wlogout \
    libnotify \
    sddm \
    tuned tuned-ppd \
    kitty \
    waybar \
    wofi \
    dunst \
    swaylock \
    hyprpolkitagent \
    alsa-sof-firmware \
    alsa-utils \
    NetworkManager-wifi iwl* \
    nm-connection-editor-desktop \
    gvfs \
    gvfs-mtp
