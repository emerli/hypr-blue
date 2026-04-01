<div align="center">

# hypr-blue

**Immutable Linux desktop, built for modern development.**

[![Build](https://github.com/emerli/hypr-blue/actions/workflows/build.yml/badge.svg)](https://github.com/emerli/hypr-blue/actions/workflows/build.yml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/base-Fedora%20Atomic%2043-blue?logo=fedora)](https://fedoraproject.org/atomic-desktops/)
[![bootc](https://img.shields.io/badge/bootc-immutable-green)](https://github.com/bootc-dev/bootc)

</div>

---

## Cos'è hypr-blue?

**hypr-blue** è un'immagine OCI bootc basata su Fedora Atomic, con **Hyprland** come desktop environment e un setup completo per lo sviluppo con **Dev Containers**.

Il sistema è immutabile: le modifiche al sistema operativo avvengono tramite rebuild dell'immagine e atomic update, non tramite modifiche manuali. Ogni tool di sviluppo gira dentro container, mantenendo il sistema pulito e riproducibile.

---

## Stack

### Desktop

| Componente | Tool |
|---|---|
| Window Manager | [Hyprland](https://hyprland.org/) |
| Status Bar | [Waybar](https://github.com/Alexays/Waybar) |
| Terminale | [Kitty](https://sw.kovidgoyal.net/kitty/) |
| Launcher | [Wofi](https://hg.sr.ht/~scoopta/wofi) |
| Notifiche | [Mako](https://github.com/emersion/mako) |
| Lock Screen | [Hyprlock](https://github.com/hyprwm/hyprlock) |
| Display Manager | [SDDM](https://github.com/sddm/sddm) |

### Sviluppo

| Componente | Tool |
|---|---|
| Editor | [VS Code](https://code.visualstudio.com/) |
| Container Runtime | [Podman](https://podman.io/) (rootless) |
| Dev Containers | VS Code Dev Containers extension |
| Build | [Buildah](https://buildah.io/) |
| Compose | [Podman Compose](https://github.com/containers/podman-compose) |

### Browser & App

- [Brave](https://brave.com/) — browser principale
- [LibreWolf](https://librewolf.net/) — browser privacy-first
- [Telegram](https://telegram.org/) — messaggistica

---

## Come funziona

Il sistema si basa su tre concetti chiave:

- **Immutabilità** — il filesystem di sistema è read-only. Le personalizzazioni vivono nell'immagine OCI.
- **Atomic updates** — `bootc upgrade` scarica la nuova immagine e la applica al prossimo boot, con rollback automatico in caso di problemi.
- **Dev Containers** — l'ambiente di sviluppo è isolato in container. VS Code si connette ai container tramite Podman, mantenendo il sistema host pulito.

```
┌─────────────────────────────────────┐
│           Sistema Host              │
│   Hyprland · Waybar · Kitty         │
│   VS Code · Podman (rootless)        │
│                                     │
│  ┌───────────────────────────────┐  │
│  │      Dev Container            │  │
│  │  Node / Go / Python / Java    │  │
│  │  dipendenze · SDK · tools     │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

---

## Installazione

### Da immagine OCI (consigliato)

Su un sistema bootc esistente (Fedora Atomic, Bazzite, Bluefin...):

```bash
sudo bootc switch ghcr.io/emerli/hypr-blue:latest
sudo reboot
```

### Da ISO

Scarica l'ultima ISO dalla sezione [Releases](../../releases) o generala tu stesso (vedi sotto).

---

## Build locale

Requisiti: `podman`, `just`

```bash
# Build immagine OCI
just build

# Genera ISO installabile
just build-iso

# Genera VM QCOW2
just build-qcow2

# Avvia VM per test
just run-vm-qcow2

# Lint script Bash
just lint
```

---

## Personalizzazione

La struttura del progetto separa nettamente **sistema** e **configurazione**:

```
build_files/packages/   # Pacchetti installati (uno script per categoria)
config/.config/         # Dotfiles → copiati in /etc/skel al build
```

Per aggiungere pacchetti, modifica lo script appropriato in `build_files/packages/` e fai il rebuild dell'immagine. Le modifiche ai dotfiles in `config/` diventano il profilo predefinito per ogni nuovo utente.

---

## CI/CD

Le GitHub Actions gestiscono automaticamente:

- **`build.yml`** — build e push dell'immagine OCI su GHCR ad ogni push su `main`
- **`build-disk.yml`** — generazione ISO e QCOW2 (trigger manuale, supporta `amd64` e `arm64`)

L'immagine viene firmata con [cosign](https://github.com/sigstore/cosign). Prima di usare i workflow, aggiungi la chiave come secret `SIGNING_SECRET` nelle impostazioni del repository.

```bash
# Genera la chiave di firma
COSIGN_PASSWORD="" cosign generate-key-pair

# Aggiungi il secret su GitHub
gh secret set SIGNING_SECRET < cosign.key
```

> [!WARNING]
> Non committare mai `cosign.key`. È già nel `.gitignore`, ma fai attenzione.

# Pubblica Immagine;Esegue build.yml che builda e pubblica latest su ghcr.io
git push origin main
# Pubblica Immagine;Esegue build-disk.yml che pulla la latest e builda e pubblica la iso
git tag v0.1 && git push origin v0.1


  1. git push origin main → aspetti che build.yml finisca e pubblichi latest su ghcr.io                        
  2. git tag v0.1 && git push origin v0.1 → parte build-disk.yml che pullerà la latest appena pubblicata


---

## Licenza

[Apache 2.0](LICENSE)

