#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable sdegler/hyprland
dnf5 -y copr enable swayfx/swayfx

dnf5 -y upgrade

source /ctx/packages/base.sh
source /ctx/packages/hyprland.sh
source /ctx/packages/sway-fx.sh
source /ctx/packages/multimedia.sh
source /ctx/packages/apps.sh
source /ctx/packages/containers.sh
source /ctx/packages/development.sh

dnf5 -y copr disable sdegler/hyprland
dnf5 -y copr disable swayfx/swayfx
dnf5 clean all

install -Dm755 /ctx/scripts/first-login-setup.sh /usr/bin/first-login-setup.sh
install -Dm644 /ctx/scripts/flatpak-apps.txt /usr/share/hypr-blue/flatpak-apps.txt
install -Dm644 /ctx/scripts/vscode-extensions.txt /usr/share/hypr-blue/vscode-extensions.txt
install -Dm644 /ctx/units/first-login-setup.service /usr/lib/systemd/user/first-login-setup.service

source /ctx/services.sh








