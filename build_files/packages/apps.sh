#!/bin/bash
set -ouex pipefail

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


