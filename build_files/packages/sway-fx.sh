#!/bin/bash
set -ouex pipefail

dnf5 install -y \
    swayfx \
    sway \
    swayidle \
    sway-contrib \
    xdg-desktop-portal-wlr
