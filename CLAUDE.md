# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Cos'è questo progetto

**hypr-blue** è un'immagine bootc personalizzata basata su Universal Blue. Produce un sistema Linux immutabile (ostree/bootc) con Hyprland come desktop environment, distribuita come immagine OCI su GHCR.

- Base: `quay.io/fedora-ostree-desktops/sway-atomic:43`
- Output: immagine OCI, ISO installabile, QCOW2 per VM

## Comandi principali (Justfile)

```bash
just --list          # elenca tutti i comandi disponibili
just build           # build immagine OCI locale con Podman
just build-iso       # genera ISO installabile
just build-qcow2     # genera VM QCOW2
just run-vm-qcow2    # avvia VM QCOW2 con QEMU
just lint            # shellcheck su tutti gli script Bash
just format          # formatta script Bash con shfmt
just clean           # rimuove artefatti di build
```

## Architettura

### Build flow

Il `Containerfile` avvia la build:
1. Copia `build_files/` e `config/` nell'immagine
2. Esegue `build_files/build.sh` che:
   - Abilita COPR `sdegler/hyprland`
   - Installa pacchetti in sequenza dai file in `build_files/packages/`
   - Esegue `services.sh` per configurare systemd

### Pacchetti (`build_files/packages/`)

Ogni file è uno script bash indipendente che installa un gruppo di pacchetti:
- `base.sh` — utility di sistema
- `hyprland.sh` — desktop Hyprland e componenti Wayland
- `multimedia.sh` — codec, ffmpeg, RPM Fusion
- `apps.sh` — Brave, LibreWolf, Telegram, LibreOffice
- `containers.sh` — Podman, Buildah, Skopeo
- `development.sh` — VS Code + Microsoft repo

### Dotfiles (`config/`)

Il contenuto di `config/` viene copiato in `/etc/skel` nell'immagine, quindi diventa il profilo predefinito per ogni nuovo utente.

Configurazioni principali:
- `config/.config/hypr/hyprland.conf` — keybindings, monitor, workspace (dwindle layout)
- `config/.config/waybar/` — barra con CPU, memoria, batteria, audio (FontAwesome 6, locale it_IT)
- `config/.config/kitty/` — terminale
- `config/.config/mako/` — notifiche

### CI/CD (`.github/workflows/`)

- `build.yml` — build immagine OCI su push/PR/schedule → `ghcr.io/<owner>/hypr-blue:latest`
- `build-disk.yml` — generazione ISO e QCOW2 (trigger manuale, supporta amd64 e arm64)

### File da non committare

- `cosign.key` — chiave di firma (già in `.gitignore`)
- `output/` — artefatti generati da bootc-image-builder
- `_build_*` — artefatti di build locali
