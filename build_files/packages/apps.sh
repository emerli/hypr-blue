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
[[ -L /opt ]] && rm /opt && mkdir /opt
mkdir -p /opt/brave.com
dnf5 install -y brave-browser

# LibreWolf — repo ufficiale
dnf5 config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf5 install -y librewolf

# Google Chrome
rpm --import https://dl.google.com/linux/linux_signing_key.pub

cat > /etc/yum.repos.d/google-chrome.repo << 'EOF'
[google-chrome]
name=Google Chrome
baseurl=https://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
EOF

dnf5 install -y google-chrome-stable

# Thunderbird
dnf5 install -y thunderbird


