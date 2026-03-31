# hypr-blue — Contesto progetto per Claude

## Descrizione
Immagine Fedora Atomic immutabile custom con **Hyprland** e **SwayFX** come WM.
Basata su `quay.io/fedora-ostree-desktops/sway-atomic:43`.
Pubblicata su `ghcr.io/emerli/hypr-blue`.

## Obiettivo
Replicare l'ambiente di sviluppo attuale su openSUSE Tumbleweed su una base immutabile
OSTree/bootc, con due WM installati per sperimentare e confrontare in condizioni reali.

---

## Architettura

### Tre layer distinti

```
1. IMMAGINE OSTree (build_files/)
   └── sistema base, Hyprland, SwayFX, browser, codec, tool

2. INIT UTENTE (scripts/init-user.sh → /usr/local/bin/init-user)
   └── configurazione generica post-installazione

3. CHEZMOI (repo privato utente)
   └── dotfile personali, credenziali, preferenze
```

### Flusso post-installazione
```bash
init-user
chezmoi init --apply https://github.com/emerli/dotfiles
```

---

## Struttura repo

```
hypr-blue/
├── Containerfile
├── build-local.sh
├── CLAUDE.md
├── build_files/
│   ├── build.sh                     # orchestratore
│   ├── services.sh                  # systemctl enable
│   └── packages/
│       ├── base.sh                  # tool di sistema
│       ├── hyprland.sh              # hyprland stack
│       ├── swayfx.sh                # swayfx stack
│       ├── browsers.sh              # brave, librewolf
│       ├── containers.sh            # podman stack
│       ├── fonts.sh                 # JetBrainsMono Nerd Font
│       └── multimedia.sh            # codec, vlc, ffmpeg
├── config/                          # va in /etc/skel
│   ├── hypr/                        # hyprland.conf
│   ├── sway/                        # sway config
│   └── waybar/
│       ├── config-hyprland.jsonc    # waybar per Hyprland
│       ├── config-sway.jsonc        # waybar per Sway
│       └── style.css                # condiviso
└── scripts/
    └── init-user.sh
```

---

## Containerfile

```dockerfile
FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora-ostree-desktops/sway-atomic:43

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
source /ctx/packages/swayfx.sh
source /ctx/packages/browsers.sh
source /ctx/packages/containers.sh
source /ctx/packages/fonts.sh
source /ctx/packages/multimedia.sh

dnf5 -y copr disable sdegler/hyprland
dnf5 -y copr disable swayfx/swayfx
dnf5 clean all

source /ctx/services.sh

install -Dm755 /ctx/scripts/init-user.sh /usr/local/bin/init-user
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

### swayfx.sh
```bash
# --allowerasing necessario: swayfx conflicta con sway dei repo ufficiali
# sway, swayidle, xdg-desktop-portal-wlr gia presenti nella base sway-atomic
dnf5 install -y --allowerasing \
    swayfx \
    sway-contrib        # contiene grimshot per screenshot
```

### browsers.sh
```bash
# Brave
rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
cat > /etc/yum.repos.d/brave-browser.repo << 'EOF'
[brave-browser]
name=Brave Browser
baseurl=https://brave-browser-rpm-release.s3.brave.com/x86_64/
enabled=1
gpgcheck=1
gpgkey=https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
EOF
mkdir -p /opt/brave.com   # workaround problema /opt su OSTree
dnf5 install -y brave-browser

# LibreWolf
dnf5 config-manager addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf5 install -y librewolf
```

### fonts.sh
```bash
NERD_FONT_VERSION="3.3.0"
curl -fLo /tmp/JetBrainsMono.tar.xz \
    https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONT_VERSION}/JetBrainsMono.tar.xz
mkdir -p /usr/share/fonts/JetBrainsMonoNF
tar -xf /tmp/JetBrainsMono.tar.xz -C /usr/share/fonts/JetBrainsMonoNF
rm /tmp/JetBrainsMono.tar.xz
fc-cache -fv
```

### containers.sh
```bash
dnf5 install -y \
    podman podman-compose buildah skopeo \
    slirp4netns fuse-overlayfs
```

### multimedia.sh
```bash
dnf5 install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf5 groupupdate -y core multimedia sound-and-video \
    --setopt='install_weak_deps=False' \
    --exclude='PackageKit-gstreamer-plugin' \
    --allowerasing

dnf5 swap -y ffmpeg-free ffmpeg --allowerasing

dnf5 install -y \
    vlc ffmpeg ffmpeg-libs libva libva-utils \
    gstreamer1-plugins-bad-free gstreamer1-plugins-good \
    gstreamer1-plugins-base gstreamer1-plugin-openh264 \
    gstreamer1-libav lame

dnf5 swap -y libva-intel-media-driver intel-media-driver --allowerasing
```

---

## services.sh

```bash
systemctl enable sddm.service
systemctl set-default graphical.target
systemctl enable podman.socket
systemctl enable fstrim.timer
systemctl enable firewalld
```

---

## Configurazioni WM

### Hyprland
- File: `config/hypr/hyprland.conf`
- COPR: `sdegler/hyprland` (solopasha abbandonato alla 0.51)
- Versione: 0.51 — usa sintassi `windowrulev2` NON blocchi `windowrule {}`
- Autostart waybar: `exec-once = waybar -c ~/.config/waybar/config-hyprland.jsonc`
- Polkit: `exec-once = systemctl --user start hyprpolkitagent`

### SwayFX
- File: `config/sway/config`
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

## init-user.sh

Script disponibile come `/usr/local/bin/init-user`. Esegue:
1. `loginctl enable-linger`
2. `podman.socket` utente
3. `DOCKER_HOST` in `.bashrc`
4. `~/.config/containers/containers.conf` e `registries.conf`
5. Flathub remote utente
6. Flatpak utente: Telegram, Spotify, Postman, Bruno, Insomnia
7. Estensioni VSCode
8. git user.name/email interattivo

---

## VSCode — packages/dev.sh (da aggiungere)

```bash
rpm --import https://packages.microsoft.com/keys/microsoft.asc
cat > /etc/yum.repos.d/vscode.repo << 'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
dnf5 install -y code
```

---

## Problemi aperti

| Problema | Stato | Note |
|---|---|---|
| Brave RPM fallisce su OSTree | Workaround | `mkdir -p /opt/brave.com` prima dell'install |
| Hyprland 0.51 invece di 0.53 | Aperto | COPR `sdegler` piu aggiornato di `solopasha` |
| `packages/dev.sh` con VSCode | Da fare | Repo Microsoft da aggiungere |
| Tema waybar Fedora | Da fare | Dopo che tutto funziona |
| style.css waybar | Da fare | Koji deve mandare il suo da Tumbleweed |

---

## Workflow di sviluppo

### Build locale
```bash
./build-local.sh
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
