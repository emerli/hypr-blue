FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/base-main:43

COPY config/common/.config/ /etc/skel/.config/
COPY config/hyprland/.config/ /etc/skel/.config/
COPY config/common/.local/ /etc/skel/.local/
COPY config/common/.bashrc config/common/.bash_profile config/common/.bash_aliases config/common/.nanorc /etc/skel/

RUN rm /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build-hyprland.sh

RUN bootc container lint
