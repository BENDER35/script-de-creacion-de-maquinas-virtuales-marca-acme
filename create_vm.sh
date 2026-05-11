#!/bin/bash

# --- creador de maquinas virtuales marca acme ---
# Features: debootstrap, chroot, Multi-Hypervisor, Guest Tools, Optional Packages, Wallpapers (Multi-Query), Host Safety

set -e
set -o pipefail

# --- Logging Setup ---
FECHA_HOY=$(date +%d-%m-%Y)
LOG_FILE="informe_imp_maqvirt(${FECHA_HOY}).log"

# Asegurar que el log sea un archivo nuevo en cada ejecución (si ya existe el del día, podemos rotarlo o añadir timestamp)
# Para cumplir estrictamente con "cree un nuevo archivo log", si ya existe uno del mismo día, le añadiremos un sufijo de tiempo para no sobrescribir sesiones previas
if [[ -f "$LOG_FILE" ]]; then
    mv "$LOG_FILE" "${LOG_FILE%.log}_$(date +%H%M%S).log"
fi

# Redirigir TODA la salida (stdout y stderr) al log y a la consola
exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    local level="${2:-INFO}"
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    # Ya no necesitamos tee aquí porque exec ya se encarga de la redirección global
    echo "[$timestamp] [$level] $message" >&2
}

# --- Cleanup Trap ---
MOUNT_DIR=""
LOOP_DEV=""
CLEANUP_DONE=0
cleanup() {
    local exit_code=$?
    if [ $CLEANUP_DONE -eq 1 ]; then return; fi
    CLEANUP_DONE=1
    
    { set +x; } 2>/dev/null
    if [ $exit_code -ne 0 ] && [ $exit_code -ne 130 ]; then
        log "ERROR DETECTADO (Código: $exit_code). Iniciando limpieza de seguridad..." "ERROR"
    else
        log "Limpieza final de montajes y dispositivos..." "DEBUG"
    fi

    if [[ -n "$MOUNT_DIR" && -d "$MOUNT_DIR" ]]; then
        log "Desmontando sistemas de archivos en $MOUNT_DIR..." "DEBUG"
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
        log "Liberando dispositivo loop $LOOP_DEV..." "DEBUG"
        sudo losetup -d "$LOOP_DEV" 2>/dev/null || true
    fi
    log "Proceso terminado." "DEBUG"
}
trap cleanup ERR EXIT INT TERM

# --- Help Function ---
show_help() {
    cat <<EOF
Uso: sudo $0 [OPCIONES]

Creador de Máquinas Virtuales Marca Acme - Script de automatización para Sistemas y Programación.

Opciones:
  --help                Muestra esta ayuda.
  --name NOMBRE         Nombre de la VM (defecto: acme_vm_[timestamp]).
  --os SO               Sistema operativo: ubuntu o debian (defecto: ubuntu).
  --hyp HYPERVISOR      Hypervisor: vbox, vmware, qemu (defecto: vbox).
  --ram MB              Cantidad de RAM en MB (defecto: 2048).
  --disk SIZE           Tamaño del disco (ej: 50G) (defecto: 50G).
  --cpucores NUM        Número de núcleos de CPU (defecto: 2).
  --user USER           Usuario del sistema (defecto: arbol).
  --pass PASS           Contraseña del usuario (defecto: tronco).
  --desktop DESKTOP     Escritorio: gnome, kde, xfce, lxde, lxqt, budgie, cinnamon, kylin, none (defecto: none).
  --mirror URL          URL del mirror personalizado.
  --verbose             Activa el modo de depuración (set -x).

Ejemplo:
  sudo $0 --name mi_servidor --os debian --ram 4096 --desktop xfce --verbose

Nota: Este script requiere privilegios de superusuario (sudo) para montar discos y ejecutar debootstrap.
EOF
    exit 0
}

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
[[ -z "$LOCALE" || "$LOCALE" == ".UTF-8" ]] && LOCALE="es_ES.UTF-8"
KEYMAP="es"
TIMEZONE=$(cat /etc/timezone 2>/dev/null || echo "Europe/Madrid")
VM_USER=""
VM_PASS=""
SELECTED_MIRROR=""
WALLHAVEN_QUERY=""
LOCAL_WP_DIR=""
EXTREPOS=""
OS_CODENAME=""
VERBOSE_MODE="n"

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        --name) NAME="$2"; shift ;;
        --os) OS="$2"; shift ;;
        --hyp) HYPERVISOR="$2"; shift ;;
        --ram) VM_RAM="$2"; shift ;;
        --disk) VM_DISK_SIZE="$2"; shift ;;
        --cpucores) VM_CPUS="$2"; shift ;;
        --user) VM_USER="$2"; shift ;;
        --pass) VM_PASS="$2"; shift ;;
        --desktop) DESKTOP="$2"; shift ;;
        --mirror) SELECTED_MIRROR="$2"; shift ;;
        --verbose) VERBOSE_MODE="s" ;;
        *) echo "Opción desconocida: $1"; show_help ;;
    esac
    shift
done

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
        # Usar curl de forma silenciosa y capturar solo el tiempo total. Forzar punto decimal.
        local time=$(curl -o /dev/null -s -I -w '%{time_total}' --connect-timeout 2 --max-time 3 "$m" | tr ',' '.' || echo 999)
        # Validar que time sea un número antes de pasarlo a bc
        if [[ ! "$time" =~ ^[0-9.]+$ ]]; then time=999; fi
        
        if (( $(echo "$time < $min_time" | bc -l) )); then
            min_time=$time; fastest=$m
        fi
    done
    [[ -n "$fastest" ]] || fastest=$([[ "$os" == "ubuntu" ]] && echo "http://archive.ubuntu.com/ubuntu/" || echo "http://deb.debian.org/debian/")
    echo "$fastest"
}

find_mirror_by_country() {
    local os=$1
    log "Detectando país por geolocalización IP..."
    local country=$(curl -s --connect-timeout 2 https://ipapi.co/country/ | tr '[:upper:]' '[:lower:]')
    
    if [[ -z "$country" || ${#country} -ne 2 ]]; then
        log "No se pudo detectar el país, usando mirror global." "WARNING"
        [[ "$os" == "ubuntu" ]] && echo "http://archive.ubuntu.com/ubuntu/" || echo "http://deb.debian.org/debian/"
        return
    fi
    
    log "País detectado: $country"
    if [[ "$os" == "ubuntu" ]]; then
        echo "http://${country}.archive.ubuntu.com/ubuntu/"
    else
        echo "http://ftp.${country}.debian.org/debian/"
    fi
}

find_fastest_mirror_parallel() {
    local os=$1
    local mirrors=()
    log "Iniciando testeo de red paralelo para encontrar el mejor mirror..."
    
    if [[ "$os" == "ubuntu" ]]; then
        mirrors=($(curl -s --connect-timeout 2 http://mirrors.ubuntu.com/mirrors.txt))
    else
        # Para Debian, usamos una lista de mirrors conocidos de alta velocidad
        mirrors=("http://deb.debian.org/debian/" "http://ftp.de.debian.org/debian/" "http://ftp.us.debian.org/debian/" "http://ftp.fr.debian.org/debian/" "http://ftp.es.debian.org/debian/" "http://mirror.hetzner.com/debian/")
    fi
    
    [[ ${#mirrors[@]} -eq 0 ]] && mirrors=($([[ "$os" == "ubuntu" ]] && echo "http://archive.ubuntu.com/ubuntu/" || echo "http://deb.debian.org/debian/"))

    local tmp_results=$(mktemp)
    
    # Lanzar pruebas en paralelo
    for m in "${mirrors[@]}"; do
        (
            [[ "${m: -1}" != "/" ]] && m="${m}/"
            local time=$(curl -o /dev/null -s -I -w '%{time_total}' --connect-timeout 2 --max-time 3 "$m" | tr ',' '.' || echo 999)
            if [[ ! "$time" =~ ^[0-9.]+$ ]]; then time=999; fi
            echo "$time $m" >> "$tmp_results"
        ) &
    done
    wait # Esperar a que terminen todos los procesos de fondo
    
    local fastest=$(sort -n "$tmp_results" | head -n 1 | awk '{print $2}')
    rm -f "$tmp_results"
    
    [[ -n "$fastest" ]] || fastest=$([[ "$os" == "ubuntu" ]] && echo "http://archive.ubuntu.com/ubuntu/" || echo "http://deb.debian.org/debian/")
    log "Mirror más rápido detectado: $fastest"
    echo "$fastest"
}

fetch_latest_versions() {
    log "Detectando codename del sistema..." "DEBUG"
    if [[ "$OS" == "ubuntu" ]]; then
        OS_CODENAME=$(curl -s https://changelogs.ubuntu.com/meta-release | grep "Dist: " | tail -1 | awk '{print $2}')
        [[ -z "$OS_CODENAME" ]] && OS_CODENAME="noble"
    else
        # Try to get testing codename if stable is too old, or just use stable
        OS_CODENAME=$(curl -s http://ftp.debian.org/debian/dists/stable/Release | grep "^Codename:" | awk '{print $2}')
        [[ -z "$OS_CODENAME" ]] && OS_CODENAME="bookworm"
    fi
    
    if [[ -z "$OS_CODENAME" ]]; then
        log "Error al detectar codename, usando valores por defecto." "WARNING"
        [[ "$OS" == "ubuntu" ]] && OS_CODENAME="noble" || OS_CODENAME="bookworm"
    fi
    log "Objetivo detectado: $OS ($OS_CODENAME)" "INFO"
}

check_dependencies() {
    log "Verificando dependencias en el host para $HYPERVISOR..." "INFO"
    local deps=("curl" "qemu-img" "zip" "7z" "rar" "openssl" "bc" "jq" "debootstrap" "parted" "kpartx" "binfmt-support" "qemu-user-static")
    [[ "$HYPERVISOR" == "vbox" ]] && deps+=("VBoxManage")
    
    local missing=()
    for dep in "${deps[@]}"; do
        local found=0
        log "Comprobando: $dep" "DEBUG"
        if command -v "$dep" &> /dev/null; then
            found=1
        elif dpkg-query -W -f='${Status}' "$dep" 2>/dev/null | grep -q "ok installed"; then
            found=1
        elif [[ "$dep" == "binfmt-support" ]] && [[ -f /usr/sbin/update-binfmts ]]; then
            found=1
        fi
        
        if [[ $found -eq 0 ]]; then
            # Special case for 7z and rar which might have different package names
            if [[ "$dep" == "7z" ]] && (command -v 7z &> /dev/null || command -v 7zr &> /dev/null); then continue; fi
            if [[ "$dep" == "rar" ]] && (command -v rar &> /dev/null || command -v unrar &> /dev/null); then continue; fi
            log "Falta dependencia: $dep" "WARNING"
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log "Instalando dependencias faltantes: ${missing[*]}" "INFO"
        sudo apt-get update
        # Use a more robust install that handles potential package name variations
        for m in "${missing[@]}"; do
            case $m in
                7z) sudo apt-get install -y p7zip-full || sudo apt-get install -y p7zip ;;
                rar) sudo apt-get install -y unrar-free || sudo apt-get install -y rar ;;
                *) sudo apt-get install -y "$m" ;;
            esac
        done
    else
        log "Todas las dependencias están presentes." "INFO"
    fi
}

# --- Menu ---
echo "--- CONFIGURACIÓN: creador de maquinas virtuales marca acme ---"

if [[ -z "$NAME" ]]; then
    read -p "Nombre de la VM: " NAME
    [[ -z "$NAME" ]] && NAME="acme_vm_$(date +%s)"
fi

if [[ -z "$HYPERVISOR" ]]; then
    echo "Hypervisor: 1) VirtualBox 2) VMware 3) QEMU"
    read -p "Opción [1]: " hyp_opt
    case $hyp_opt in 2) HYPERVISOR="vmware" ;; 3) HYPERVISOR="qemu" ;; *) HYPERVISOR="vbox" ;; esac
fi

check_dependencies

if [[ -z "$OS" ]]; then
    echo "Sistema: 1) Ubuntu 2) Debian"
    read -p "Opción [1]: " os_opt
    case $os_opt in 2) OS="debian" ;; *) OS="ubuntu" ;; esac
fi

read -p "RAM (MB) [$VM_RAM]: " input_ram; [[ -n "$input_ram" ]] && VM_RAM="$input_ram"
read -p "Disco (ej: 50G) [$VM_DISK_SIZE]: " input_disk; [[ -n "$input_disk" ]] && VM_DISK_SIZE="$input_disk"
# Validación de tamaño de disco: si es solo numérico, añadir 'G' por defecto
if [[ "$VM_DISK_SIZE" =~ ^[0-9]+$ ]]; then
    log "No se detectó unidad en el tamaño del disco, asumiendo Gigabytes (G)." "WARNING"
    VM_DISK_SIZE="${VM_DISK_SIZE}G"
fi

read -p "Núcleos de CPU [$VM_CPUS]: " input_cpus; [[ -n "$input_cpus" ]] && VM_CPUS="$input_cpus"

read -p "Idioma [$LOCALE]: " input_locale; [[ -n "$input_locale" ]] && LOCALE="$input_locale"
read -p "Teclado [$KEYMAP]: " input_keymap; [[ -n "$input_keymap" ]] && KEYMAP="$input_keymap"
read -p "Zona Horaria [$TIMEZONE]: " input_tz; [[ -n "$input_tz" ]] && TIMEZONE="$input_tz"

if [[ -z "$VM_USER" ]]; then
    read -p "¿Desea un usuario y una contraseña personalizada? (s/n) [n]: " set_auth
    if [[ "$set_auth" == "s" || "$set_auth" == "S" ]]; then
        read -p "Usuario: " VM_USER
        read -s -p "Contraseña: " VM_PASS
        echo ""
    else
        VM_USER="arbol"
        VM_PASS="tronco"
    fi
fi
[[ -z "$VM_USER" ]] && VM_USER="arbol"
[[ -z "$VM_PASS" ]] && VM_PASS="tronco"

echo "Software Opcional (presiona Enter para saltar):"
read -p "Paquetes APT (ej: htop,ncdu) [ninguno]: " OPT_APT
read -p "Paquetes Flatpak (ej: vlc,spotify) [ninguno]: " OPT_FLATPAK
read -p "Paquetes Snap (ej: slack,discord) [ninguno]: " OPT_SNAP

if [[ -z "$SELECTED_MIRROR" ]]; then
    echo "Mirrors: t) Default y) Manual l) busqueda del mirror mas rapido (por pais) b) busqueda de los mirrors mas rapidos (testeo de red)"
    read -n 1 -p "Opción [l]: " mirror_choice; echo ""
    case $mirror_choice in
        t|T) SELECTED_MIRROR=$([[ "$OS" == "ubuntu" ]] && echo "http://archive.ubuntu.com/ubuntu/" || echo "http://deb.debian.org/debian/") ;;
        y|Y) read -p "URL del Mirror: " SELECTED_MIRROR ;;
        b|B) SELECTED_MIRROR=$(find_fastest_mirror_parallel "$OS") ;;
        *) SELECTED_MIRROR=$(find_mirror_by_country "$OS") ;;
    esac
fi
[[ "${SELECTED_MIRROR: -1}" != "/" ]] && SELECTED_MIRROR="${SELECTED_MIRROR}/"

read -p "¿Repositorio extrepo? (ej: vscode,signal) [ninguno]: " EXTREPOS

if [[ -z "$DESKTOP" ]]; then
    if [[ "$OS" == "ubuntu" ]]; then
        while true; do
            echo "Escritorio: 1) GNOME 2) KDE 3) XFCE 4) LXDE 5) LXQt 6) Budgie 7) gnome(edub.) 8) cinnamon(ub) 9) Kylin 10) MATE 11) KDE(studio) 12) Ninguno"
            read -p "Selecciona escritorio [12]: " desk_opt
            case $desk_opt in
                1) DESKTOP="gnome"; break ;;
                2) DESKTOP="kde"; break ;;
                3) DESKTOP="xfce"; break ;;
                4) DESKTOP="lxde"; break ;;
                5) DESKTOP="lxqt"; break ;;
                6) DESKTOP="budgie"; break ;;
                7) DESKTOP="edubuntu"; break ;;
                8) DESKTOP="cinnamon"; break ;;
                9) DESKTOP="kylin"; break ;;
                10) 
                    echo "AVISO: esta distro solo esta hasta 25.10 continuo y esta en proceso de reestructuracion del equipo directivo del sabor de ubuntu, con lo cual es posible que pueda eliminarse esta opcion en un futuro si canonical decide quitar este sabor (edicion) de su oferta, ¿estas seguro que quieres continuar? (S/N)"
                    read -n 1 -p "Opción: " confirm_mate; echo ""
                    if [[ "$confirm_mate" == "s" || "$confirm_mate" == "S" ]]; then
                        DESKTOP="mate"
                        break
                    else
                        echo "Regresando a la selección de escritorios..."
                        continue
                    fi
                    ;;
                11) DESKTOP="ubuntustudio"; break ;;
                *) DESKTOP="none"; break ;;
            esac
        done
    else
        echo "Escritorio: 1) GNOME 2) KDE 3) XFCE 4) LXDE 5) LXQt 6) Budgie 7) Ninguno"
        read -p "Selecciona escritorio [7]: " desk_opt
        case $desk_opt in
            1) DESKTOP="gnome" ;; 2) DESKTOP="kde" ;; 3) DESKTOP="xfce" ;; 4) DESKTOP="lxde" ;; 5) DESKTOP="lxqt" ;; 6) DESKTOP="budgie" ;; *) DESKTOP="none" ;;
        esac
    fi
fi

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
        # Limpiar espacios en blanco
        q=$(echo "$q" | xargs)
        log "Buscando: $q..."
        QUERY_ENC=$(echo -n "$q" | jq -sRr @uri)
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
log "Iniciando creación de disco de tamaño $VM_DISK_SIZE..." "INFO"
qemu-img create -f raw "$RAW_DISK" "$VM_DISK_SIZE"

log "Particionando disco con tabla msdos..." "INFO"
sudo parted -s "$RAW_DISK" mklabel msdos mkpart primary ext4 1M 100% set 1 boot on
LOOP_DEV=$(sudo losetup -Pf --show "$RAW_DISK")
log "Disco asociado a $LOOP_DEV" "DEBUG"
PART_DEV="${LOOP_DEV}p1"
log "Formateando partición $PART_DEV en EXT4..." "INFO"
sudo mkfs.ext4 "$PART_DEV"

MOUNT_DIR=$(mktemp -d /tmp/vm_mount.XXXXXX)
log "Montando sistema de archivos en $MOUNT_DIR..." "DEBUG"
sudo mount "$PART_DEV" "$MOUNT_DIR"

if [[ ! -e "/usr/share/debootstrap/scripts/$OS_CODENAME" ]]; then
    log "Ajustando script de debootstrap para $OS_CODENAME (fallback)..." "WARNING"
    LATEST_SCRIPT=$(ls -v /usr/share/debootstrap/scripts/ | grep -E '^[a-z]+$' | tail -n 1)
    log "Usando script base: $LATEST_SCRIPT" "DEBUG"
    sudo ln -sf "$LATEST_SCRIPT" "/usr/share/debootstrap/scripts/$OS_CODENAME"
fi

log "Ejecutando debootstrap (esto puede tardar varios minutos)..." "INFO"
log "Mirror: $SELECTED_MIRROR | Codename: $OS_CODENAME" "DEBUG"
sudo debootstrap --arch amd64 "$OS_CODENAME" "$MOUNT_DIR" "$SELECTED_MIRROR"

# --- CHROOT CONFIG ---
log "Preparando fase CHROOT..." "INFO"

# Determinar paquetes de herramientas de invitado y kernel (Host Logic)
G_PKG=""
if [[ "$HYPERVISOR" == "vbox" ]]; then
    G_PKG="virtualbox-guest-x11 virtualbox-guest-utils"
    [[ "$OS" == "debian" ]] && G_PKG="$G_PKG virtualbox-guest-dkms"
elif [[ "$HYPERVISOR" == "vmware" ]]; then
    G_PKG="open-vm-tools-desktop"
elif [[ "$HYPERVISOR" == "qemu" ]]; then
    G_PKG="qemu-guest-agent"
fi

if [[ "$OS" == "ubuntu" ]]; then
    KERNEL_PKGS="linux-image-generic grub-pc"
else
    KERNEL_PKGS="linux-image-amd64 grub-pc"
    [[ "$HYPERVISOR" == "vbox" ]] && KERNEL_PKGS="$KERNEL_PKGS linux-headers-amd64 build-essential"
fi

cat <<CHROOT_SCRIPT > "$CONFIG_DIR/$NAME/setup.sh"
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# No set -e here to allow custom error handling for optional packages
set +e
[[ "$VERBOSE_MODE" == "s" ]] && set -x

echo "Configurando sistema (chroot phase)..."

echo "$NAME" > /etc/hostname
echo "127.0.0.1 localhost $NAME" > /etc/hosts

echo "Configurando repositorios..."
if [[ "$OS" == "ubuntu" ]]; then
    echo "deb $SELECTED_MIRROR $OS_CODENAME main restricted universe multiverse" > /etc/apt/sources.list
    echo "deb $SELECTED_MIRROR $OS_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list
    echo "deb $SELECTED_MIRROR $OS_CODENAME-security main restricted universe multiverse" >> /etc/apt/sources.list
else
    # Debian: ensure contrib, non-free and backports are always there (Fast Track requirement)
    echo "deb $SELECTED_MIRROR $OS_CODENAME main contrib non-free non-free-firmware" > /etc/apt/sources.list
    echo "deb $SELECTED_MIRROR $OS_CODENAME-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
    echo "deb $SELECTED_MIRROR $OS_CODENAME-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
    echo "deb http://security.debian.org/debian-security $OS_CODENAME-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
fi

echo "Actualizando listas de paquetes..."
apt-get update

echo "Configurando red (Opción 1: Nativa)..."
if [[ "$OS" == "ubuntu" ]]; then
    echo "Instalando netplan.io..."
    apt-get install -y netplan.io
    mkdir -p /etc/netplan
    cat <<EOF_NET > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    all-interfaces:
      match:
        name: "e*"
      dhcp4: true
EOF_NET
    chmod 600 /etc/netplan/01-netcfg.yaml
else
    echo "Instalando ifupdown..."
    apt-get install -y ifupdown
    cat <<EOF_NET > /etc/network/interfaces
auto lo
iface lo inet loopback

# Configuración para interfaces comunes (enp0s3, eth0, etc.)
allow-hotplug enp0s3
iface enp0s3 inet dhcp

allow-hotplug eth0
iface eth0 inet dhcp

allow-hotplug enp0s8
iface enp0s8 inet dhcp
EOF_NET
fi

# Pre-crear directorios que suelen causar fallos en scripts de post-instalación de paquetes (como plymouth)
mkdir -p /etc/initramfs-tools/conf.d

echo "Instalando paquetes base (locales, sudo)..."
apt-get install -y locales sudo tzdata console-setup

echo "Configurando locale y zona horaria..."
# Generamos el locale antes de intentar usarlo para evitar advertencias de Perl
sed -i "s/^# *$LOCALE/$LOCALE/" /etc/locale.gen || echo "$LOCALE UTF-8" >> /etc/locale.gen
locale-gen
update-locale LANG=$LOCALE
export LANG=$LOCALE
export LC_ALL=$LOCALE

ln -fs /usr/share/zoneinfo/$TIMEZONE /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

if [[ "$OS" == "debian" && "$HYPERVISOR" == "vbox" ]]; then
    echo "Configurando soporte para VirtualBox en Debian (Fast Track)..."
    apt-get install -y wget gnupg
    # Importar llave desde servidor de llaves (ID de Fast Track: AD743EF7)
    # Fingerprint: B490 2862 8D3F B7C0 AB8F B014 C47F 8A8A AD74 3EF7
    echo "Obteniendo llave GPG de Fast Track desde keyserver..."
    gpg --keyserver keyserver.ubuntu.com --recv-keys AD743EF7 || \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys AD743EF7 || \
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys AD743EF7
    
    gpg --export AD743EF7 > /usr/share/keyrings/debian-fasttrack-archive-keyring.gpg
    
    echo "deb [signed-by=/usr/share/keyrings/debian-fasttrack-archive-keyring.gpg] http://fasttrack.debian.net/debian-fasttrack $OS_CODENAME-fasttrack main contrib" > /etc/apt/sources.list.d/fasttrack.list
    apt-get update
fi

if id "$VM_USER" &>/dev/null; then
    echo "El usuario $VM_USER ya existe, actualizando configuración..."
else
    echo "Creando usuario $VM_USER..."
    useradd -m -s /bin/bash "$VM_USER"
fi
echo "$VM_USER:$VM_PASS" | chpasswd
[[ "$VM_USER" != "root" ]] && echo "$VM_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$VM_USER

echo "Instalando kernel y grub..."
# Pre-configurar grub-pc
echo "grub-pc grub-pc/install_devices multiselect \$1" | debconf-set-selections
echo "grub-pc grub-pc/install_devices_empty boolean false" | debconf-set-selections
apt-get install -y $KERNEL_PKGS

echo "Configurando GRUB..."
apt-get purge -y os-prober
if grep -q "GRUB_DISABLE_OS_PROBER" /etc/default/grub; then
    sed -i 's/^#*GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=true/' /etc/default/grub
else
    echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
fi

grub-install --target=i386-pc --force --modules=part_msdos "\$1"
update-grub

echo "Instalando herramientas básicas..."
apt-get install -y openssh-server curl git wget

echo "Instalando Guest Tools ($HYPERVISOR)..."
# Install guest tools individually to prevent one missing package from failing the whole build
for pkg in $G_PKG; do
    echo "Intentando instalar \$pkg..."
    apt-get install -y \$pkg || echo "Advertencia: No se pudo instalar \$pkg"
done

# Reparar dependencias rotas si las hay antes de paquetes opcionales
dpkg --configure -a
apt-get install -f -y

if [[ -n "$OPT_APT" ]]; then 
    echo "Instalando paquetes APT opcionales..."
    for p in ${OPT_APT//,/ }; do
        apt-get install -y \$p || echo "Error instalando \$p"
    done
fi

if [[ -n "$OPT_FLATPAK" ]]; then
    echo "Configurando Flatpak..."
    # Flatpak requiere bubblewrap para el sandboxing
    apt-get install -y flatpak bubblewrap
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    for p in ${OPT_FLATPAK//,/ }; do 
        echo "Instalando flatpak: \$p"
        # Si el nombre no parece un ID completo (necesita al menos 2 puntos), intentamos buscarlo
        if [[ "\$p" == *.*.* ]]; then
            flatpak install -y flathub "\$p" || echo "Error al instalar flatpak \$p"
        else
            echo "Buscando ID para \$p..."
            ID=\$(flatpak search "\$p" | head -n 1 | awk '{print \$2}')
            if [[ -n "\$ID" ]]; then
                echo "ID encontrado: \$ID. Instalando..."
                flatpak install -y flathub "\$ID" || echo "Error al instalar flatpak \$ID"
            else
                echo "No se encontró un ID unívoco para \$p, intentando instalación directa..."
                flatpak install -y flathub "\$p" || echo "Error al instalar flatpak \$p (puede requerir sesión de usuario)"
            fi
        fi
    done
fi

if [[ -n "$OPT_SNAP" ]]; then
    echo "Configurando Snap..."
    # Snap requiere dbus y squashfs-tools. En chroot el daemon no corre, pero instalamos los paquetes.
    apt-get install -y snapd dbus-user-session squashfs-tools
    for s in ${OPT_SNAP//,/ }; do 
        echo "Instalando snap: \$s"
        # Intentar instalar, pero ignorar fallos de comunicación con el daemon (común en chroot)
        snap install "\$s" || echo "Aviso: Snap \$s no se instaló (el daemon snapd no suele estar activo en chroot). Se intentará en el primer arranque."
    done
fi

if [[ "$DESKTOP" != "none" ]]; then
    echo "Instalando entorno de escritorio: $DESKTOP..."
    if [[ "$OS" == "ubuntu" ]]; then
        case "$DESKTOP" in
            gnome) apt-get install -y ubuntu-desktop ;;
            kde) apt-get install -y kubuntu-desktop ;;
            xfce) apt-get install -y xubuntu-desktop ;;
            lxde) apt-get install -y lubuntu-desktop ;;
            lxqt) apt-get install -y lubuntu-desktop ;;
            budgie) apt-get install -y ubuntu-budgie-desktop ;;
            edubuntu) apt-get install -y edubuntu-desktop ;;
            cinnamon) apt-get install -y ubuntucinnamon-desktop ;;
            kylin) apt-get install -y ubuntukylin-desktop ;;
            mate) apt-get install -y ubuntu-mate-desktop ;;
            ubuntustudio) apt-get install -y ubuntustudio-desktop ubuntustudio-default-settings ;;
        esac
    else
        apt-get install -y task-${DESKTOP}-desktop
    fi
fi

if [[ -n "$EXTREPOS" && "$EXTREPOS" != "n" && "$EXTREPOS" != "no" ]]; then
    echo "Habilitando repositorios extrepo..."
    apt-get install -y extrepo
    # extrepo enable puede fallar si el repo ya existe o no se encuentra, manejamos con || true
    IFS=',' read -ra ADDR <<< "$EXTREPOS"; for i in "\${ADDR[@]}"; do 
        echo "Habilitando extrepo: \$i"
        extrepo enable "\$i" || echo "No se pudo habilitar extrepo: \$i"
    done
    apt-get update
fi

echo "Instalando wallpapers..."
mkdir -p /usr/share/backgrounds/acme
cp /tmp/wallpapers/* /usr/share/backgrounds/acme/ 2>/dev/null || true
CHROOT_SCRIPT

UUID=$(sudo blkid -s UUID -o value "$PART_DEV")
log "UUID de la partición: $UUID" "DEBUG"
echo "UUID=$UUID / ext4 errors=remount-ro 0 1" | sudo tee "$MOUNT_DIR/etc/fstab"
sudo cp "$CONFIG_DIR/$NAME/setup.sh" "$MOUNT_DIR/setup.sh"
sudo chmod +x "$MOUNT_DIR/setup.sh"
sudo mkdir -p "$MOUNT_DIR/tmp/wallpapers"
[[ -d "$CONFIG_DIR/$NAME/wallpapers" ]] && sudo cp "$CONFIG_DIR/$NAME/wallpapers/"* "$MOUNT_DIR/tmp/wallpapers/" 2>/dev/null || true

log "Iniciando configuración interna en CHROOT..." "INFO"
for d in dev dev/pts proc sys run; do 
    log "Montando $d..." "DEBUG"
    sudo mount --bind /$d "$MOUNT_DIR/$d"
done
sudo chroot "$MOUNT_DIR" /bin/bash /setup.sh "$LOOP_DEV"

log "Configuración CHROOT finalizada. Limpiando montajes..." "INFO"
for d in run sys proc dev/pts dev; do 
    log "Desmontando $d..." "DEBUG"
    sudo umount -l "$MOUNT_DIR/$d"
done
sudo umount -l "$MOUNT_DIR"
sudo losetup -d "$LOOP_DEV"
LOOP_DEV=""

# --- CONVERSION ---
log "Iniciando fase de conversión de disco para $HYPERVISOR..." "INFO"
if [[ "$HYPERVISOR" == "vbox" ]]; then
    if command -v VBoxManage &> /dev/null; then
        log "Convirtiendo RAW a VDI..." "DEBUG"
        VBoxManage convertfromraw "$RAW_DISK" "$VM_PATH/${NAME}.vdi" --format VDI
        log "Registrando máquina virtual en VirtualBox..." "DEBUG"
        VBoxManage createvm --name "$NAME" --register --basefolder "$(pwd)/$VM_DIR"
        log "Configurando hardware de la VM (RAM: $VM_RAM MB, CPUs: $VM_CPUS)..." "DEBUG"
        VBoxManage modifyvm "$NAME" --cpus "$VM_CPUS" --memory "$VM_RAM" --vram 128 --graphicscontroller vmsvga --boot1 disk --nic1 nat --mouse usbtablet
        log "Adjuntando disco duro..." "DEBUG"
        VBoxManage storagectl "$NAME" --name "SATA" --add sata
        VBoxManage storageattach "$NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VM_PATH/${NAME}.vdi"
        log "Adjuntando unidad óptica vacía..." "DEBUG"
        VBoxManage storageattach "$NAME" --storagectl "SATA" --port 1 --device 0 --type dvddrive --medium emptydrive
    else
        log "VBoxManage no encontrado, saltando registro de VM. El disco está en $RAW_DISK" "WARNING"
    fi
elif [[ "$HYPERVISOR" == "vmware" ]]; then
    log "Convirtiendo RAW a VMDK..." "DEBUG"
    qemu-img convert -f raw -O vmdk "$RAW_DISK" "$VM_PATH/${NAME}.vmdk"
    log "Generando archivo de configuración VMX..." "DEBUG"
    cat <<EOF > "$VM_PATH/${NAME}.vmx"
.encoding = "UTF-8"
config.version = "8"; virtualHW.version = "14"; memsize = "$VM_RAM"; numvcpus = "$VM_CPUS"; guestOS = "ubuntu-64"; displayname = "$NAME"
scsi0.present = "TRUE"; scsi0.virtualDev = "lsilogic"; scsi0:0.present = "TRUE"; scsi0:0.fileName = "${NAME}.vmdk"
ethernet0.present = "TRUE"; ethernet0.connectionType = "nat"; ethernet0.virtualDev = "e1000"
EOF
else
    log "Convirtiendo RAW a QCOW2..." "DEBUG"
    qemu-img convert -f raw -O qcow2 "$RAW_DISK" "$VM_PATH/${NAME}.qcow2"
fi
rm -f "$RAW_DISK"

# --- PACKAGING ---
if [[ "$COMPRESS_FORMAT" != "none" ]]; then
    log "Empaquetando máquina virtual en formato $COMPRESS_FORMAT..." "INFO"
    case $COMPRESS_FORMAT in
        zip) zip -r "${NAME}.zip" "$VM_PATH" ;;
        rar) rar a "${NAME}.rar" "$VM_PATH" ;;
        7z) 7z a "${NAME}.7z" "$VM_PATH" && 7z t "${NAME}.7z" || { log "Error en 7z, usando respaldo ZIP" "WARNING"; zip -r "${NAME}.zip" "$VM_PATH"; } ;;
    esac
    log "Limpiando archivos temporales de construcción..." "DEBUG"
    rm -rf "$VM_PATH" "$CONFIG_DIR/$NAME"
fi

log "¡Proceso finalizado correctamente!" "INFO"
exit 0
