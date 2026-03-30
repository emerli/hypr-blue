#!/bin/bash
set -ouex pipefail

# RPM Fusion free e nonfree
dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm


dnf5 group install -y multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

dnf5 swap -y ffmpeg-free ffmpeg --allowerasing


dnf5 install -y \
    vlc \
    ffmpeg \
    ffmpeg-libs \
    libva \
    libva-utils \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-good \
    gstreamer1-plugins-base \
    gstreamer1-plugin-openh264 \
    gstreamer1-libav \
    lame

dnf5 swap -y libva-intel-media-driver intel-media-driver --allowerasing
