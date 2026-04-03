#!/bin/bash
set -ouex pipefail

# ublue base già include: podman, buildah, skopeo, slirp4netns, fuse-overlayfs

dnf5 install -y podman-compose
