#!/bin/bash
set -ouex pipefail

dnf5 install -y \
    hyprland hyprland-guiutils hyprland-qt-support \
    hyprpaper hyprlock hypridle \
    xdg-desktop-portal-hyprland \
    hyprpolkitagent
