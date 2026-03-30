#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# sostituisci il contenuto con qualcosa tipo
dnf5 -y copr enable sdegler/hyprland

dnf5 -y update

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
    fontawesome-6-brands-fonts \
    fontawesome-6-free-fonts \
    jetbrains-mono-fonts-all \
    sddm \
    tuned tuned-ppd \
    kitty \
    waybar \
    wofi \
    dunst \
    swaylock \
    hyprpolkitagent \
    nautilus \
    alsa-sof-firmware \
    alsa-utils \
    NetworkManager-wifi iwl* \
    nm-connection-editor-desktop \
    gvfs \
    gvfs-mtp \
    nano \
   bash

dnf5 -y upgrade

dnf5 -y copr disable sdegler/hyprland


systemctl enable sddm.service
systemctl set-default graphical.target

systemctl enable podman.socket

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File






