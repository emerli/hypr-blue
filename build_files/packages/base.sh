#!/bin/bash
set -ouex pipefail

# ublue base già include: curl, wget, nano, htop, zip, unzip, rsync,
# alsa-sof-firmware, alsa-utils, NetworkManager-wifi, wl-clipboard,
# libnotify, firewalld, flatpak, pipewire, wireplumber, polkit, xwayland

dnf5 install -y \
    git neovim \
    7zip meld ripgrep inotify-tools wev hdparm plocate \
    openconnect NetworkManager-openconnect NetworkManager-openconnect-gnome \
    tuned tuned-ppd tuned-switcher \
    sddm \
    mate-polkit \
    swaylock \
    waybar wofi kitty \
    pavucontrol network-manager-applet nm-connection-editor blueman \
    wlogout brightnessctl playerctl mako \
    gvfs gvfs-client gvfs-mtp gvfs-smb gvfs-gphoto2 \
    grim grimshot slurp \
    kanshi wlr-randr wlsunset xdg-user-dirs xsettingsd \
    fontawesome-6-brands-fonts fontawesome-6-free-fonts \
    jetbrains-mono-fonts-all \
    thunar mousepad thunar-archive-plugin thunar-volman tumbler xarchiver \
    catfish gigolo ristretto evince foliate \
    system-config-printer \
    fprintd fprintd-pam \
    mobile-broadband-provider-info bolt \
    pinentry-gnome3 gnome-keyring gnome-keyring-pam
