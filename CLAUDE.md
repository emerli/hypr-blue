# hypr-blue — Contesto progetto per Claude

## Descrizione
Immagine Fedora Atomic immutabile custom con **Hyprland** e **SwayFX** come WM.
Basata su `quay.io/fedora-ostree-desktops/sway-atomic:43`.
Pubblicata su `ghcr.io/emerli/hypr-blue`.
Orientata agli sviluppatori: VSCode, podman, glab, ansible inclusi nell'immagine.

## Obiettivo
Replicare l'ambiente di sviluppo attuale su openSUSE Tumbleweed su una base immutabile
OSTree/bootc, con due WM installati per sperimentare e confrontare in condizioni reali.

---

## Architettura

### Tre layer distinti

```
1. IMMAGINE OSTree (build_files/)
   └── sistema base, Hyprland, SwayFX, browser, codec, tool dev
       dotfiles in /etc/skel, VSCode settings in /etc/skel/.config/

2. FIRST LOGIN (build_files/scripts/first-login-setup.sh)
   └── systemd user service oneshot — eseguito una volta al primo login
       installa flatpak (Spotify, Bruno) e estensioni VSCode

3. ANSIBLE (ansible/) — non committato nel repo
   └── configurazione strettamente personale:
       SSH keys, git config, Claude config, Thunderbird profilo, Maven, VPN
```

### Flusso post-installazione
```bash
# Al primo login il servizio first-login-setup gira automaticamente.
# Poi l'utente esegue manualmente l'Ansible per la config personale:
cd ansible && ansible-playbook site.yml --ask-vault-pass
```

---

## Struttura repo

```
hypr-blue/
├── Containerfile
├── CLAUDE.md
├── .gitignore                       # include ansible/
├── build_files/
│   ├── build.sh                     # orchestratore
│   ├── services.sh                  # systemctl enable
│   ├── packages/
│   │   ├── base.sh                  # tool di sistema
│   │   ├── hyprland.sh              # hyprland stack
│   │   ├── sway-fx.sh               # swayfx stack
│   │   ├── apps.sh                  # browser, telegram, thunderbird
│   │   ├── containers.sh            # podman stack
│   │   ├── development.sh           # VSCode, ansible, glab
│   │   ├── fonts.sh                 # JetBrainsMono Nerd Font
│   │   └── multimedia.sh            # codec, vlc, ffmpeg
│   ├── scripts/
│   │   ├── first-login-setup.sh     # script primo login
│   │   ├── flatpak-apps.txt         # lista app flatpak
│   │   └── vscode-extensions.txt    # lista estensioni VSCode
│   └── units/
│       └── first-login-setup.service
├── config/                          # va in /etc/skel
│   ├── .bashrc
│   ├── .bash_profile
│   ├── .bash_aliases
│   ├── .nanorc
│   ├── .config/
│   │   ├── Code/User/settings.json  # VSCode settings
│   │   ├── hypr/                    # hyprland.conf
│   │   ├── sway/                    # sway config
│   │   └── waybar/
│   │       ├── config-hyprland.jsonc
│   │       ├── config-sway.jsonc
│   │       └── style.css
│   └── .local/
└── ansible/                         # ignorato da git
    ├── ansible.cfg
    ├── site.yml
    ├── inventory
    ├── group_vars/all/
    │   ├── all.yml
    │   └── vault.yml                # cifrato con ansible-vault
    └── roles/
        ├── dotfiles/                # SSH keys+config, Claude config, git config
        ├── thunderbird/             # user.js profilo Gmail
        ├── development/             # Claude Code CLI
        └── tabaccai/                # Maven settings.xml, VPN nmcli
```

---

## Containerfile

```dockerfile
FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora-ostree-desktops/sway-atomic:43

COPY config/.config/ /etc/skel/.config/
COPY config/.local/ /etc/skel/.local/
COPY config/.bashrc config/.bash_profile config/.bash_aliases config/.nanorc /etc/skel/

RUN rm /opt && mkdir /opt

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

RUN bootc container lint
```

---

## build.sh

```bash
#!/bin/bash
set -ouex pipefail

dnf5 -y copr enable sdegler/hyprland
dnf5 -y copr enable swayfx/swayfx
dnf5 -y upgrade

source /ctx/packages/base.sh
source /ctx/packages/hyprland.sh
source /ctx/packages/sway-fx.sh
source /ctx/packages/multimedia.sh
source /ctx/packages/apps.sh
source /ctx/packages/containers.sh
source /ctx/packages/development.sh

dnf5 -y copr disable sdegler/hyprland
dnf5 -y copr disable swayfx/swayfx
dnf5 clean all

source /ctx/services.sh

install -Dm755 /ctx/scripts/first-login-setup.sh /usr/bin/first-login-setup.sh
install -Dm644 /ctx/scripts/flatpak-apps.txt /usr/share/hypr-blue/flatpak-apps.txt
install -Dm644 /ctx/scripts/vscode-extensions.txt /usr/share/hypr-blue/vscode-extensions.txt
install -Dm644 /ctx/units/first-login-setup.service /usr/lib/systemd/user/first-login-setup.service
```

---

## packages/

### base.sh
```bash
dnf5 install -y \
    git curl wget nano neovim htop \
    zip unzip p7zip p7zip-plugins \
    rsync meld libreoffice \
    openconnect NetworkManager-openconnect \
    flatpak plocate firewalld chezmoi
```

### hyprland.sh
```bash
dnf5 install -y \
    hyprland hyprland-guiutils hyprland-qt-support \
    hyprpaper hyprlock hypridle \
    xdg-desktop-portal-hyprland \
    wl-clipboard mako brightnessctl playerctl \
    pavucontrol network-manager-applet blueman \
    wlogout libnotify \
    fontawesome-6-brands-fonts fontawesome-6-free-fonts \
    jetbrains-mono-fonts-all \
    sddm tuned tuned-ppd \
    kitty waybar wofi dunst swaylock \
    hyprpolkitagent nautilus \
    alsa-sof-firmware alsa-utils \
    NetworkManager-wifi nm-connection-editor-desktop \
    gvfs gvfs-mtp
```

### sway-fx.sh
```bash
dnf5 install -y --allowerasing \
    swayfx \
    sway-contrib
```

### apps.sh
```bash
# Telegram
dnf5 install -y telegram-desktop

# Brave
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
# ... repo setup ...
dnf5 install -y brave-browser

# LibreWolf
dnf5 config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf5 install -y librewolf

# Google Chrome
rpm --import https://dl.google.com/linux/linux_signing_key.pub
# ... repo setup ...
dnf5 install -y google-chrome-stable

# Thunderbird
dnf5 install -y thunderbird
```

### development.sh
```bash
# VSCode
rpm --import https://packages.microsoft.com/keys/microsoft.asc
# ... repo setup ...
dnf5 install -y code ansible glab
```

### containers.sh
```bash
dnf5 install -y \
    podman podman-compose buildah skopeo \
    slirp4netns fuse-overlayfs
```

### fonts.sh
```bash
# JetBrainsMono Nerd Font da GitHub releases
curl -fLo /tmp/JetBrainsMono.tar.xz \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/JetBrainsMono.tar.xz
mkdir -p /usr/share/fonts/JetBrainsMonoNF
tar -xf /tmp/JetBrainsMono.tar.xz -C /usr/share/fonts/JetBrainsMonoNF
fc-cache -fv
```

### multimedia.sh
```bash
# RPMFusion free + nonfree
# dnf5 groupupdate multimedia sound-and-video
# ffmpeg, vlc, gstreamer plugins, intel-media-driver
```

---

## services.sh

```bash
systemctl enable sddm.service
systemctl --global enable first-login-setup.service
systemctl set-default graphical.target
systemctl enable podman.socket
systemctl enable fstrim.timer
systemctl enable firewalld
```

---

## first-login-setup

Servizio systemd user **oneshot** abilitato globalmente. Eseguito una sola volta al primo login.
Guard file: `~/.config/hypr-blue/.first-login-done`

```
build_files/scripts/
├── first-login-setup.sh      # script principale
├── flatpak-apps.txt          # una app per riga (com.spotify.Client, ...)
└── vscode-extensions.txt     # una estensione per riga
```

Al termine invia notifica via `notify-send`: **"Configurazione Terminata"**

Per aggiungere flatpak o estensioni: editare i rispettivi `.txt`.

---

## Ansible (configurazione personale)

Non committato nel repo (in `.gitignore`). Da eseguire manualmente dopo il primo login.

```bash
cd ansible && ansible-playbook site.yml --ask-vault-pass
```

### Roles
| Role | Contenuto |
|---|---|
| `dotfiles` | SSH keys+config, Claude CLAUDE.md+settings.json, git global config |
| `thunderbird` | user.js per profilo Gmail (da eseguire dopo primo avvio TB: `--tags thunderbird`) |
| `development` | Claude Code CLI |
| `tabaccai` | ~/.m2/settings.xml, VPN Tabaccai via nmcli |

### vault.yml
Cifrato con `ansible-vault`. Contiene le chiavi SSH private.

---

## Configurazioni WM

### Hyprland
- File: `config/.config/hypr/hyprland.conf`
- COPR: `sdegler/hyprland`
- Versione: 0.54.3 — usa blocchi `windowrule {}` e `layerrule = rule, match:namespace ^pattern$`
- Autostart waybar: `exec-once = waybar -c ~/.config/waybar/config-hyprland.jsonc`
- Polkit: `exec-once = systemctl --user start hyprpolkitagent`

### SwayFX
- File: `config/.config/sway/config`
- Drop-in replacement di Sway — stessa sintassi config
- Effetti: `corner_radius`, `shadows`, `blur`, `default_dim_inactive`
- Autostart waybar: `exec waybar -c ~/.config/waybar/config-sway.jsonc`
- Screenshot: `grimshot` da `sway-contrib`
- Screen sharing: solo monitor intero — no window picking (limite wlr-screencopy)

### Differenze Hyprland → Sway
| Hyprland | Sway |
|---|---|
| `exec-once` | `exec` |
| `bind` | `bindsym` |
| `bindel/bindl` | `bindsym --locked` |
| `windowrule {}` | `assign` + `for_window` |
| `hyprland/workspaces` | `sway/workspaces` |
| `hyprland/window` | `sway/window` |
| `hyprshot` | `grimshot` |

---

## Waybar

### Due config separati, style.css condiviso
- `config-hyprland.jsonc` — moduli `hyprland/workspaces`, `hyprland/window`
- `config-sway.jsonc` — moduli `sway/workspaces`, `sway/window`
- `style.css` — identico per entrambi

### Font
- JetBrainsMono Nerd Font — installato da `fonts.sh`
- Font Awesome 6 Free + Brands — nei repo Fedora

### Icone workspace (Font Awesome 6 Free)
| Workspace | Uso | Unicode |
|---|---|---|
| 1 | Chat/Telegram | `\uf086` |
| 2 | Browser | `\uf0ac` |
| 3 | Terminale | `\uf120` |
| 4 | VSCode | `\uf121` |
| 5 | File manager | `\uf07b` |
| 6-7 | Vuoti | `○` |
| 8 | Email | `\uf0e0` |
| 9 | Musica | `\uf001` |
| 10 | Browser 2 | `\uf0ac` |

---

## XDG Desktop Portal

### Hyprland
```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.ScreenCast=hyprland
org.freedesktop.impl.portal.Screenshot=hyprland
```
Supporta window picking nativo.

### Sway/SwayFX
```ini
[preferred]
default=gtk
org.freedesktop.impl.portal.ScreenCast=wlr
org.freedesktop.impl.portal.Screenshot=wlr
```
Solo monitor intero — no window picking.

---

## Problemi aperti

| Problema | Stato | Note |
|---|---|---|
| Brave RPM fallisce su OSTree | Workaround | `rm /opt && mkdir /opt` nel Containerfile |
| Hyprland 0.51 invece di 0.53 | Aperto | COPR `sdegler` piu aggiornato di `solopasha` |
| Tema waybar Fedora | Da fare | Dopo che tutto funziona |
| style.css waybar | Da fare | Koji deve mandare il suo da Tumbleweed |
| ISO > 2GB, release GitHub disabilitata | Chiuso | La base `sway-atomic:43` pesa già 2.1GB compressa — impossibile stare sotto i 2GB senza cambiare base. Distribuzione via `rpm-ostree rebase` da ghcr.io è il metodo corretto per bootc/OSTree. |

---

## Workflow di sviluppo

### Build locale
```bash
./build_files/build_local.sh
# build + tag + push su registry locale localhost:5000
```

### Registry locale per VM
```bash
# host
podman run -d -p 0.0.0.0:5000:5000 --name registry docker.io/library/registry:2
sudo firewall-cmd --zone=libvirt --add-port=5000/tcp

# VM — /etc/containers/registries.conf
# [[registry]]
# location = "192.168.122.1:5000"
# insecure = true

# VM
sudo rpm-ostree upgrade && reboot
```

### Release
```bash
git push origin main   # GitHub Action builda e pubblica su ghcr.io
```

### Comandi OSTree utili
```bash
rpm-ostree status       # immagine attiva e staged
rpm-ostree upgrade      # aggiorna alla versione piu recente
rpm-ostree rebase <ref> # cambia sorgente immagine
rpm-ostree rollback     # torna all immagine precedente
```

---

## Note tecniche OSTree

- `/home` non fa parte dell immagine — persiste tra gli aggiornamenti
- `/etc/skel` → copiato in home solo per nuovi utenti (non su rebase)
- `/opt` su Fedora Atomic e symlink a `/var/opt` — problematico durante build RPM
- Il digest SHA256 determina se c e qualcosa da aggiornare
- COPR vanno sempre disabilitati dopo l uso
- `rpm-ostree upgrade` != `rpm-ostree rebase` — errore comune!
