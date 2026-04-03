#!/bin/bash
set -ouex pipefail

dnf5 install -y --allowerasing \
    swayfx swayidle swaybg \
    sway-contrib sway-systemd \
    xdg-desktop-portal-wlr \
    sddm-wayland-sway \
    dunst
