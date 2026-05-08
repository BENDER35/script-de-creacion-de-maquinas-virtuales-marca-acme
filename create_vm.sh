#!/bin/bash

# --- creador de maquinas virtuales marca acme ---
# Features: debootstrap, chroot, Multi-Hypervisor, Guest Tools, Optional Packages, Wallpapers (Multi-Query), Host Safety

set -e
set -o pipefail

# --- Logging Setup ---
LOG_FILE="vm_creator.log"
log() {
    local message="$1"
    local xtrace_state=$(shopt -p -o xtrace)
    { set +x; } 2>/dev/null
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE" >&2
    eval "$xtrace_state"
}

# --- Cleanup Trap ---
MOUNT_DIR=""
LOOP_DEV=""
cleanup() {
    local exit_code=$?
    { set +x; } 2>/dev/null
    if [ $exit_code -ne 0 ]; then
        log "ERROR DETECTADO (Código: $exit_code). Iniciando limpieza de seguridad..."
    else
        log "Limpieza final de montajes y dispositivos..."
    fi

    if [[ -n "$MOUNT_DIR" && -d "$MOUNT_DIR" ]]; then
        for d in run sys proc dev/pts dev tmp/wallpapers; do
            if mountpoint -q "$MOUNT_DIR/$d"; then
                sudo umount -l "$MOUNT_DIR/$d" 2>/dev/null || true
            fi
        done
        if mountpoint -q "$MOUNT_DIR"; then
            sudo umount -l "$MOUNT_DIR" 2>/dev/null || true
        fi
        rm -rf "$MOUNT_DIR"
    fi
    if [[ -n "$LOOP_DEV" ]]; then
        sudo losetup -d "$LOOP_DEV" 2>/dev/null || true
    fi
    log "Proceso terminado."
}
trap cleanup ERR EXIT

# --- Default Configurations ---
VM_RAM=2048
VM_CPUS=2
VM_DISK_SIZE="50G"
VM_DIR="./vms"
CONFIG_DIR="./configs"
OPT_APT=""
OPT_FLATPAK=""
OPT_SNAP=""
DESKTOP=""
COMPRESS_FORMAT=""
LOCALE=$(echo $LANG | cut -d. -f1).UTF-8
[[ -z "$LOCALE" ]] && LOCALE="es_ES.UTF-8"
KEYMAP="es"
TIMEZONE=$(cat /etc/timezone 2>/dev/null || echo "Europe/Madrid")
VM_USER="user"
VM_PASS="password"
SELECTED_MIRROR=""
WALLHAVEN_QUERY=""
LOCAL_WP_DIR=""
EXTREPOS=""
OS_CODENAME=""
VERBOSE_MODE="n"

# --- Mirror Selection Logic ---
find_fastest_mirror() {
    local os=$1
    local mirrors=()
    log "Analizando mirrors para encontrar el más rápido..."
    if [[ "$os" == "ubuntu" ]]; then
        mirrors=($(curl -s http://mirrors.ubuntu.com/mirrors.txt | head -n 10))
        [[ ${#mirrors[@]} -eq 0 ]] && mirrors=("http://archive.ubuntu.com/ubuntu/" "http://es.archive.ubuntu.com/ubuntu/")
    else
        mirrors=("http://deb.debian.org/debian/" "http://ftp.es.debian.org/debian/" "http://mirror.hetzner.com/debian/")
    fi
    
    local fastest=""
    local min_time=999
    for m in "${mirrors[@]}"; do
        [[ "${m: -1}" != "/" ]] && m="${m}/"
        local time=$(curl -o /dev/null -s -I -w '%{time_total}\n' --connect-timeout 2 --max-time 3 "$m" || echo 999)
        if (( $(echo "$time < $min_time" | bc -l) )); then
            min_time=$time; fastest=$m
        fi
    done
    [[ -n "$fastest" ]] || fastest="http://archive.ubuntu.com/ubuntu/"
    echo "$fastest"
}

fetch_latest_versions() {
    log "Detectando codename del sistema..."
    if [[ "$OS" == "ubuntu" ]]; then
        OS_CODENAME=$(curl -s https://changelogs.ubuntu.com/meta-release | grep "Dist: " | tail -1 | awk '{print $2}')
        [[ -z "$OS_CODENAME" ]] && OS_CODENAME="noble"
    else
        OS_CODENAME=$(curl -s http://ftp.debian.org/debian/dists/stable/Release | grep "^Codename:" | awk '{print $2}')
        [[ -z "$OS_CODENAME" ]] && OS_CODENAME="bookworm"
    fi
    log "Objetivo: $OS ($OS_CODENAME)"
}

check_dependencies() {
    log "Verificando dependencias del host..."
    local deps=("curl" "qemu-img" "zip" "7z" "rar" "openssl" "bc" "jq" "debootstrap" "parted" "kpartx" "binfmt-support" "qemu-user-static")
    local missing=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then missing+=("$dep"); fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "Instalando: ${missing[*]}"
        sudo apt-get update && sudo apt-get install -y "${missing[@]}"
    fi
}

# --- Menu ---
echo "--- CONFIGURACIÓN: creador de maquinas virtuales marca acme ---"
check_dependencies
read -p "Nombre de la VM: " NAME
[[ -z "$NAME" ]] && NAME="acme_vm_$(date +%s)"

echo "Hypervisor: 1) VirtualBox 2) VMware 3) QEMU"
read -p "Opción [1]: " hyp_opt
case $hyp_opt in 2) HYPERVISOR="vmware" ;; 3) HYPERVISOR="qemu" ;; *) HYPERVISOR="vbox" ;; esac

echo "Sistema: 1) Ubuntu 2) Debian"
read -p "Opción [1]: " os_opt
case $os_opt in 2) OS="debian" ;; *) OS="ubuntu" ;; esac

read -p "RAM (MB) [$VM_RAM]: " input_ram; [[ -n "$input_ram" ]] && VM_RAM="$input_ram"
read -p "Disco (ej: 50G) [$VM_DISK_SIZE]: " input_disk; [[ -n "$input_disk" ]] && VM_DISK_SIZE="$input_disk"
read -p "Idioma [$LOCALE]: " input_locale; [[ -n "$input_locale" ]] && LOCALE="$input_locale"
read -p "Teclado [$KEYMAP]: " input_keymap; [[ -n "$input_keymap" ]] && KEYMAP="$input_keymap"
read -p "Zona Horaria [$TIMEZONE]: " input_tz; [[ -n "$input_tz" ]] && TIMEZONE="$input_tz"

read -p "¿Usuario/Pass personalizados? (s/n) [n]: " set_auth
if [[ "$set_auth" == "s" ]]; then
    read -p "Usuario: " VM_USER; read -s -p "Contraseña: " VM_PASS; echo ""
fi

echo "Software Opcional:"
read -p "Paquetes APT (ej: htop,ncdu): " OPT_APT
read -p "Paquetes Flatpak (ej: vlc,spotify): " OPT_FLATPAK
read -p "Paquetes Snap (ej: slack,discord): " OPT_SNAP

echo "Mirrors: t) Default Y) Manual f) Fastest"
read -n 1 -p "Opción [f]: " mirror_choice; echo ""
case $mirror_choice in
    t|T) SELECTED_MIRROR=$([[ "$OS" == "ubuntu" ]] && echo "http://archive.ubuntu.com/ubuntu/" || echo "http://deb.debian.org/debian/") ;;
    y|Y) read -p "URL del Mirror: " SELECTED_MIRROR ;;
    *) SELECTED_MIRROR=$(find_fastest_mirror "$OS") ;;
esac
[[ "${SELECTED_MIRROR: -1}" != "/" ]] && SELECTED_MIRROR="${SELECTED_MIRROR}/"

read -p "¿Repositorio extrepo?: " EXTREPOS

echo "Escritorio: 1) GNOME 2) KDE 3) XFCE 4) LXDE 5) LXQt 6) Budgie 7) Ninguno"
read -p "Selecciona escritorio [7]: " desk_opt
case $desk_opt in
    1) DESKTOP="gnome" ;; 2) DESKTOP="kde" ;; 3) DESKTOP="xfce" ;; 4) DESKTOP="lxde" ;; 5) DESKTOP="lxqt" ;; 6) DESKTOP="budgie" ;; *) DESKTOP="none" ;;
esac

echo "Compresión: 1) zip 2) rar 3) 7z 4) Ninguna"
read -p "Selecciona compresión [4]: " comp_opt
case $comp_opt in 1) COMPRESS_FORMAT="zip" ;; 2) COMPRESS_FORMAT="rar" ;; 3) COMPRESS_FORMAT="7z" ;; *) COMPRESS_FORMAT="none" ;; esac

read -p "¿Fondos de Wallhaven? (ej: pokemon,digimon): " WALLHAVEN_QUERY
read -p "¿Fondos locales? (Ruta): " LOCAL_WP_DIR
read -p "¿Modo Verbose? (s/n) [n]: " VERBOSE_MODE

log "Configuración finalizada. Iniciando construcción..."
[[ "$VERBOSE_MODE" == "s" ]] && set -x

# --- CORE ---
mkdir -p "$VM_DIR" "$CONFIG_DIR/$NAME"
fetch_latest_versions

if [[ -n "$WALLHAVEN_QUERY" ]]; then
    log "Descargando fondos de Wallhaven para las búsquedas: $WALLHAVEN_QUERY"
    mkdir -p "$CONFIG_DIR/$NAME/wallpapers"
    global_count=1
    IFS=',' read -ra QUERIES <<< "$WALLHAVEN_QUERY"
    for q in "${QUERIES[@]}"; do
        log "Buscando: $q..."
        QUERY_ENC=$(echo "$q" | jq -sRr @uri)
        API_URL="https://wallhaven.cc/api/v1/search?q=${QUERY_ENC}&sorting=random&atleast=1920x1080&per_page=10"
        WP_URLS=$(curl -s "$API_URL" | jq -r '.data[].path' | head -n 10)
        for u in $WP_URLS; do
            log "Bajando fondo $global_count..."
            curl -s -L -o "$CONFIG_DIR/$NAME/wallpapers/wp_$global_count.jpg" "$u"
            ((global_count++))
        done
    done
fi
if [[ -n "$LOCAL_WP_DIR" && -d "$LOCAL_WP_DIR" ]]; then
    mkdir -p "$CONFIG_DIR/$NAME/wallpapers"
    cp "$LOCAL_WP_DIR"/*.{jpg,png,jpeg} "$CONFIG_DIR/$NAME/wallpapers/" 2>/dev/null || true
fi

VM_PATH="$VM_DIR/$NAME"; mkdir -p "$VM_PATH"
RAW_DISK="$VM_PATH/${NAME}.raw"
log "Creando disco..."
qemu-img create -f raw "$RAW_DISK" "$VM_DISK_SIZE"

log "Particionando disco..."
sudo parted -s "$RAW_DISK" mklabel msdos mkpart primary ext4 1M 100% set 1 boot on
LOOP_DEV=$(sudo losetup -Pf --show "$RAW_DISK")
PART_DEV="${LOOP_DEV}p1"
sudo mkfs.ext4 "$PART_DEV"

MOUNT_DIR=$(mktemp -d /tmp/vm_mount.XXXXXX)
sudo mount "$PART_DEV" "$MOUNT_DIR"

if [[ ! -e "/usr/share/debootstrap/scripts/$OS_CODENAME" ]]; then
    log "Ajustando script de debootstrap para $OS_CODENAME..."
    LATEST_SCRIPT=$(ls -v /usr/share/debootstrap/scripts/ | grep -E '^[a-z]+$' | tail -n 1)
    sudo ln -sf "$LATEST_SCRIPT" "/usr/share/debootstrap/scripts/$OS_CODENAME"
fi

log "Ejecutando debootstrap..."
sudo debootstrap --arch amd64 "$OS_CODENAME" "$MOUNT_DIR" "$SELECTED_MIRROR"

# --- CHROOT CONFIG ---
log "Iniciando fase CHROOT..."
cat <<CHROOT_SCRIPT > "$CONFIG_DIR/$NAME/setup.sh"
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
set -e
echo "Configurando sistema..."

echo "$NAME" > /etc/hostname
echo "127.0.0.1 localhost $NAME" > /etc/hosts

if [[ "$OS" == "ubuntu" ]]; then
    echo "deb $SELECTED_MIRROR $OS_CODENAME main restricted universe multiverse" > /etc/apt/sources.list
    echo "deb $SELECTED_MIRROR $OS_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list
else
    echo "deb $SELECTED_MIRROR $OS_CODENAME main" > /etc/apt/sources.list
fi
apt-get update

apt-get install -y locales tzdata sudo console-setup
echo "$LOCALE UTF-8" > /etc/locale.gen && locale-gen
update-locale LANG=$LOCALE && ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

useradd -m -s /bin/bash "$VM_USER"
echo "$VM_USER:$VM_PASS" | chpasswd
echo "$VM_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$VM_USER

if [[ "$OS" == "ubuntu" ]]; then apt-get install -y linux-image-generic grub-pc
else apt-get install -y linux-image-amd64 grub-pc
fi

# Aislamiento total: eliminar os-prober y forzar desactivación en config
apt-get purge -y os-prober || true
if grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
    sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
else
    echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
fi

grub-install --target=i386-pc --force --modules=part_msdos "\$1"
update-grub

G_PKG=""
[[ "$HYPERVISOR" == "vbox" ]] && G_PKG="virtualbox-guest-x11 virtualbox-guest-utils"
[[ "$HYPERVISOR" == "vmware" ]] && G_PKG="open-vm-tools-desktop"
[[ "$HYPERVISOR" == "qemu" ]] && G_PKG="qemu-guest-agent"
apt-get install -y openssh-server curl git wget \$G_PKG

if [[ -n "$OPT_APT" ]]; then apt-get install -y ${OPT_APT//,/ }; fi
if [[ -n "$OPT_FLATPAK" ]]; then
    apt-get install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    for p in ${OPT_FLATPAK//,/ }; do flatpak install -y flathub \$p || true; done
fi
if [[ -n "$OPT_SNAP" ]]; then
    apt-get install -y snapd
    for s in ${OPT_SNAP//,/ }; do snap install \$s || echo "Snap \$s pendiente"; done
fi

if [[ "$DESKTOP" != "none" ]]; then
    if [[ "$OS" == "ubuntu" ]]; then
        case "$DESKTOP" in
            gnome) apt-get install -y ubuntu-desktop ;;
            kde) apt-get install -y kubuntu-desktop ;;
            xfce) apt-get install -y xubuntu-desktop ;;
            lxde) apt-get install -y lubuntu-desktop ;;
            lxqt) apt-get install -y lubuntu-desktop ;;
            budgie) apt-get install -y ubuntu-budgie-desktop ;;
        esac
    else
        apt-get install -y task-${DESKTOP}-desktop
    fi
fi

if [[ -n "$EXTREPOS" ]]; then
    apt-get install -y extrepo
    IFS=',' read -ra ADDR <<< "$EXTREPOS"; for i in "\${ADDR[@]}"; do extrepo enable "\$i"; done
    apt-get update
fi

mkdir -p /usr/share/backgrounds/acme
cp /tmp/wallpapers/* /usr/share/backgrounds/acme/ 2>/dev/null || true
CHROOT_SCRIPT

UUID=$(sudo blkid -s UUID -o value "$PART_DEV")
echo "UUID=$UUID / ext4 errors=remount-ro 0 1" | sudo tee "$MOUNT_DIR/etc/fstab"
sudo cp "$CONFIG_DIR/$NAME/setup.sh" "$MOUNT_DIR/setup.sh"
sudo chmod +x "$MOUNT_DIR/setup.sh"
sudo mkdir -p "$MOUNT_DIR/tmp/wallpapers"
[[ -d "$CONFIG_DIR/$NAME/wallpapers" ]] && sudo cp "$CONFIG_DIR/$NAME/wallpapers/"* "$MOUNT_DIR/tmp/wallpapers/" 2>/dev/null || true

log "Iniciando configuración en CHROOT..."
for d in dev dev/pts proc sys run; do sudo mount --bind /$d "$MOUNT_DIR/$d"; done
sudo chroot "$MOUNT_DIR" /bin/bash /setup.sh "$LOOP_DEV"

log "Limpiando montajes..."
for d in run sys proc dev/pts dev; do sudo umount -l "$MOUNT_DIR/$d"; done
sudo umount -l "$MOUNT_DIR"
sudo losetup -d "$LOOP_DEV"
LOOP_DEV=""

# --- CONVERSION ---
log "Convirtiendo disco..."
if [[ "$HYPERVISOR" == "vbox" ]]; then
    VBoxManage convertfromraw "$RAW_DISK" "$VM_PATH/${NAME}.vdi" --format VDI
    VBoxManage createvm --name "$NAME" --register --basefolder "$(pwd)/$VM_DIR"
    VBoxManage modifyvm "$NAME" --cpus "$VM_CPUS" --memory "$VM_RAM" --vram 128 --graphicscontroller vmsvga --boot1 disk --nic1 nat --mouse usbtablet
    VBoxManage storagectl "$NAME" --name "SATA" --add sata && VBoxManage storageattach "$NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VM_PATH/${NAME}.vdi"
elif [[ "$HYPERVISOR" == "vmware" ]]; then
    qemu-img convert -f raw -O vmdk "$RAW_DISK" "$VM_PATH/${NAME}.vmdk"
    cat <<EOF > "$VM_PATH/${NAME}.vmx"
.encoding = "UTF-8"
config.version = "8"; virtualHW.version = "14"; memsize = "$VM_RAM"; numvcpus = "$VM_CPUS"; guestOS = "ubuntu-64"; displayname = "$NAME"
scsi0.present = "TRUE"; scsi0.virtualDev = "lsilogic"; scsi0:0.present = "TRUE"; scsi0:0.fileName = "${NAME}.vmdk"
ethernet0.present = "TRUE"; ethernet0.connectionType = "nat"; ethernet0.virtualDev = "e1000"
EOF
else
    qemu-img convert -f raw -O qcow2 "$RAW_DISK" "$VM_PATH/${NAME}.qcow2"
fi
rm -f "$RAW_DISK"

# --- PACKAGING ---
if [[ "$COMPRESS_FORMAT" != "none" ]]; then
    log "Empaquetando máquina virtual..."
    case $COMPRESS_FORMAT in
        zip) zip -r "${NAME}.zip" "$VM_PATH" ;;
        rar) rar a "${NAME}.rar" "$VM_PATH" ;;
        7z) 7z a "${NAME}.7z" "$VM_PATH" && 7z t "${NAME}.7z" || { log "Error en 7z, usando respaldo ZIP"; zip -r "${NAME}.zip" "$VM_PATH"; } ;;
    esac
    rm -rf "$VM_PATH" "$CONFIG_DIR/$NAME"
fi

log "¡Proceso finalizado correctamente!"
