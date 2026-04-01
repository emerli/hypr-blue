#!/bin/bash
set -ouex pipefail

systemctl enable sddm.service
systemctl --global enable first-login-setup.service
systemctl set-default graphical.target
systemctl enable podman.socket
systemctl enable fstrim.timer
systemctl enable firewalld
