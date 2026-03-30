#!/bin/bash
set -ouex pipefail

# Telegram RPM nativo
dnf5 install -y telegram-desktop

# Brave Browser
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc

cat > /etc/yum.repos.d/brave-browser.repo << 'EOF'
[brave-browser]
name=Brave Browser
baseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
EOF

dnf5 install -y brave-browser

# LibreWolf — repo ufficiale
dnf5 config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf5 install -y librewolf


