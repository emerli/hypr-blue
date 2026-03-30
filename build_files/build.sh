#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable sdegler/hyprland

dnf5 -y upgrade

source /ctx/packages/base.sh
source /ctx/packages/hyprland.sh
source /ctx/packages/multimedia.sh
source /ctx/packages/apps.sh
source /ctx/packages/containers.sh
source /ctx/packages/development.sh

dnf5 -y copr disable sdegler/hyprland
dnf5 clean all

source /ctx/services.sh








