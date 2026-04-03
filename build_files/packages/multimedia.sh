#!/bin/bash
set -ouex pipefail

# ublue base già include: ffmpeg, ffmpeg-libs, libva, libva-utils,
# gstreamer1-plugins-base/good/bad-free, gstreamer1-plugin-libav

# RPM Fusion (necessario per plugin aggiuntivi)
dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 install -y \
    gstreamer1-plugin-openh264 \
    lame

dnf5 swap -y libva-intel-media-driver intel-media-driver --allowerasing
