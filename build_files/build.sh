#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
# sostituisci il contenuto con qualcosa tipo
dnf5 -y copr enable solopasha/hyprland

dnf5 install -y \
    hyprland \
    sddm \
    sddm-breeze \
    tuned tuned-ppd \
    kitty \
    waybar \
    wofi \
    dunst \
    swaylock \
    hyprpolkitagent \
    nautilus \
    pavucontrol \
    alsa-sof-firmware \
    alsa-utils \
    blueman \
    NetworkManager-wifi iwl* \
    nm-connection-editor-desktop \
    gvfs \
    gvfs-mtp \
    xdg-desktop-portal-hyprland \
    hyprpaper \
    hyprlock \
    nano \
   bash

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

systemctl enable podman.socket




