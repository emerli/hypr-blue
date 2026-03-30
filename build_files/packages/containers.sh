#!/bin/bash
set -ouex pipefail

dnf5 install -y \
    podman \
    podman-compose \
    buildah \
    skopeo \
    slirp4netns \
    fuse-overlayfs
