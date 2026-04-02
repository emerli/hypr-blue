#!/bin/bash
# Eseguito una volta al primo login utente tramite systemd user service

set -euo pipefail

SCRIPT_DIR=/usr/share/hypr-blue

# Flatpak
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
while IFS= read -r app; do
    flatpak install --user --noninteractive flathub "$app"
done < "${SCRIPT_DIR}/flatpak-apps.txt"

# VSCode extensions
while IFS= read -r ext; do
    code --install-extension "$ext"
done < "${SCRIPT_DIR}/vscode-extensions.txt"

# Developer tools
curl -fsSL https://claude.ai/install.sh | bash
curl -fsSL https://mise.run | sh
curl -fsSL https://opencode.ai/install | sh
~/.local/bin/mise use --global ansible glab

notify-send "hypr-blue" "Configurazione Terminata" --icon=system-software-install
