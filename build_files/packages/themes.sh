#!/bin/bash
set -ouex pipefail

# ── Icone: Papirus-Dark ───────────────────────────────────────────────────────
dnf5 install -y papirus-icon-theme

# ── Catppuccin GTK theme ──────────────────────────────────────────────────────
# Tema GTK3 + GTK4 (include override per libadwaita)
CATPPUCCIN_GTK_TAG="v1.0.3"
CATPPUCCIN_GTK_NAME="catppuccin-mocha-standard-blue-dark"
curl -fLo /tmp/catppuccin-gtk.zip \
    "https://github.com/catppuccin/gtk/releases/download/${CATPPUCCIN_GTK_TAG}/${CATPPUCCIN_GTK_NAME}.zip"
mkdir -p /usr/share/themes
unzip -o /tmp/catppuccin-gtk.zip -d /usr/share/themes/
rm /tmp/catppuccin-gtk.zip

# ── Catppuccin cursors ────────────────────────────────────────────────────────
CATPPUCCIN_CURSORS_TAG="v2.0.0"
CATPPUCCIN_CURSORS_NAME="catppuccin-mocha-dark-cursors"
curl -fLo /tmp/catppuccin-cursors.zip \
    "https://github.com/catppuccin/cursors/releases/download/${CATPPUCCIN_CURSORS_TAG}/${CATPPUCCIN_CURSORS_NAME}.zip"
unzip -o /tmp/catppuccin-cursors.zip -d /usr/share/icons/
rm /tmp/catppuccin-cursors.zip

# ── Papirus folders: colori Catppuccin Mocha Blue ────────────────────────────
curl -fLo /tmp/papirus-folders \
    "https://raw.githubusercontent.com/catppuccin/papirus-folders/main/papirus-folders"
chmod +x /tmp/papirus-folders
/tmp/papirus-folders --theme Papirus-Dark --color cat-mocha-blue
rm /tmp/papirus-folders
