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
    if [[ -n "$KEYRING_DIR" && -d "$KEYRING_DIR" ]]; then
        rm -rf "$KEYRING_DIR" 2>/dev/null || true
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
  --os SO               Sistema operativo: ubuntu, debian, kali o parrot (defecto: ubuntu).
  --edition EDICION     Edición/tipo para Kali o Parrot. Kali: default, large, everything,
                        headless, core, purple. Parrot: security, home, core, htb.
  --hyp HYPERVISOR      Hypervisor: vbox, vmware, qemu, raw, rootfs, vagrant, hyperv (defecto: vbox).
  --ram MB              Cantidad de RAM en MB (defecto: 2048).
  --disk SIZE           Tamaño del disco (ej: 50G) (defecto: 50G).
  --cpucores NUM        Número de núcleos de CPU (defecto: 2).
  --user USER           Usuario del sistema (defecto: arbol).
  --pass PASS           Contraseña del usuario (defecto: tronco).
  --flatpak PKGS        Lista de paquetes Flatpak separados por comas (ej: vlc,spotify).
  --desktop DESKTOP     Escritorio: gnome, kde, xfce, lxde, lxqt, budgie, cinnamon, kylin,
                        mate, edubuntu, ubuntustudio, skolelinux, kali-<de>, parrot-<de>, none.
  --mirror URL          URL del mirror personalizado.
  --verbose             Activa el modo de depuración (set -x).

Ejemplo:
  sudo $0 --name lab_seguridad --os parrot --edition security --desktop xfce --ram 4096

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
OS=""
OS_CODENAME=""
DISTRO_EDITION=""
HYPERVISOR=""
KEYRING_DIR=""
BOOTSTRAP_KEYRING=""
GUEST_KEYRING_NAME=""
VERBOSE_MODE="n"

# --- Argument Parsing ---
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help) show_help ;;
        --name) NAME="$2"; shift ;;
        --os) OS="$2"; shift ;;
        --edition) DISTRO_EDITION="$2"; shift ;;
        --hyp) HYPERVISOR="$2"; shift ;;
        --ram) VM_RAM="$2"; shift ;;
        --disk) VM_DISK_SIZE="$2"; shift ;;
        --cpucores) VM_CPUS="$2"; shift ;;
        --user) VM_USER="$2"; shift ;;
        --pass) VM_PASS="$2"; shift ;;
        --flatpak) OPT_FLATPAK="$2"; shift ;;
        --desktop) DESKTOP="$2"; shift ;;
        --mirror) SELECTED_MIRROR="$2"; shift ;;
        --verbose) VERBOSE_MODE="s" ;;
        *) echo "Opción desconocida: $1"; show_help ;;
    esac
    shift
done

# --- Validación de argumentos ---
if [[ -n "$OS" ]]; then
    case "$OS" in
        ubuntu|debian|kali|parrot) ;;
        *) log "Sistema operativo no soportado: '$OS'. Use: ubuntu, debian, kali o parrot." "ERROR"; exit 1 ;;
    esac
fi
if [[ -n "$HYPERVISOR" ]]; then
    case "$HYPERVISOR" in
        vbox|vmware|qemu|raw|rootfs|vagrant|hyperv) ;;
        *) log "Hypervisor no soportado: '$HYPERVISOR'. Use: vbox, vmware, qemu, raw, rootfs, vagrant o hyperv." "ERROR"; exit 1 ;;
    esac
fi

# --- Mirror Selection Logic ---
find_fastest_mirror() {
    local os=$1
    local mirrors=()
    log "Analizando mirrors para encontrar el más rápido..."
    case "$os" in
        kali) echo "http://http.kali.org/kali/"; return ;;
        parrot) echo "https://deb.parrot.sh/parrot/"; return ;;
    esac
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
    case "$os" in
        kali) echo "http://http.kali.org/kali/"; return ;;
        parrot) echo "https://deb.parrot.sh/parrot/"; return ;;
    esac
    log "Detectando país por geolocalización IP..."
    local country=$(curl -s --connect-timeout 2 https://ipapi.co/country/ | tr '[:upper:]' '[:lower:]' || true)
    
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
    case "$os" in
        kali) echo "http://http.kali.org/kali/"; return ;;
        parrot) echo "https://deb.parrot.sh/parrot/"; return ;;
    esac

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
    # Respetar un codename ya seleccionado por el usuario (--os o menú)
    if [[ -n "$OS_CODENAME" ]]; then
        log "Usando codename seleccionado manualmente: $OS ($OS_CODENAME)" "INFO"
        return
    fi
    case "$OS" in
        ubuntu)
            OS_CODENAME=$(curl -s https://changelogs.ubuntu.com/meta-release | grep "Dist: " | tail -1 | awk '{print $2}' || true)
            [[ -z "$OS_CODENAME" ]] && OS_CODENAME="noble"
            ;;
        kali)
            OS_CODENAME="kali-rolling"
            ;;
        parrot)
            OS_CODENAME="parrot"
            ;;
        *)
            # Debian: codename de la rama estable actual
            OS_CODENAME=$(curl -s http://ftp.debian.org/debian/dists/stable/Release | grep "^Codename:" | awk '{print $2}' || true)
            [[ -z "$OS_CODENAME" ]] && OS_CODENAME="bookworm"
            ;;
    esac

    if [[ -z "$OS_CODENAME" ]]; then
        log "Error al detectar codename, usando valores por defecto." "WARNING"
        [[ "$OS" == "ubuntu" ]] && OS_CODENAME="noble" || OS_CODENAME="bookworm"
    fi
    log "Objetivo detectado: $OS ($OS_CODENAME)" "INFO"
}

analyze_snaps() {
    local snaps=$1
    [[ -z "$snaps" ]] && return
    if ! command -v snap &> /dev/null; then
        log "Comando 'snap' no encontrado en el host. Se delegará toda la detección a la VM." "WARNING"
        SNAP_DATA_HOST=""
        return
    fi
    log "Analizando snaps seleccionados en el host ($snaps)..." "INFO"
    SNAP_DATA_HOST=""
    for s in ${snaps//,/ }; do
        log "Consultando info de: $s..." "DEBUG"
        local info=$(snap info "$s" 2>/dev/null || echo "")
        local flags=""
        if echo "$info" | grep -q "classic"; then
            flags="--classic"
        fi
        # Si no hay versión estable pero sí otras, marcamos para que la VM pruebe canales
        SNAP_DATA_HOST+="${s}:${flags} "
    done
    SNAP_DATA_HOST=$(echo "$SNAP_DATA_HOST" | xargs)
}

check_dependencies() {
    log "Verificando dependencias en el host para $HYPERVISOR..." "INFO"
    local deps=("curl" "qemu-img" "zip" "7z" "rar" "openssl" "bc" "jq" "debootstrap" "parted" "kpartx" "binfmt-support" "qemu-user-static" "tar" "gzip")
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
        elif [[ "$dep" == "qemu-user-static" ]] && (ls /usr/bin/qemu-*-static &>/dev/null || ls /usr/bin/qemu-*-binfmt &>/dev/null); then
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
        sudo apt-get update || log "No se pudo actualizar la lista de paquetes del host." "WARNING"
        # Use a more robust install that handles potential package name variations.
        # Los fallos no son fatales: se avisa y se continúa (p.ej. qemu-user no es necesario en builds amd64).
        for m in "${missing[@]}"; do
            case $m in
                7z) sudo apt-get install -y p7zip-full || sudo apt-get install -y p7zip || log "No se pudo instalar 7z (p7zip)." "WARNING" ;;
                rar) sudo apt-get install -y unrar-free || sudo apt-get install -y rar || log "No se pudo instalar rar/unrar." "WARNING" ;;
                qemu-user-static) sudo apt-get install -y qemu-user-static || sudo apt-get install -y qemu-user-binfmt || sudo apt-get install -y qemu-user-binfmt-hwe || log "No se pudo instalar emulación qemu-user (no necesaria para builds amd64)." "WARNING" ;;
                VBoxManage) log "VBoxManage no encontrado. Instala VirtualBox para exportar en formato VDI." "WARNING" ;;
                *) sudo apt-get install -y "$m" || log "No se pudo instalar $m." "WARNING" ;;
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
    echo "Formato/Hypervisor: 1) VirtualBox 2) VMware 3) QEMU 4) RAW 5) RootFS 6) Vagrant 7) Hyper-V"
    read -p "Opción [1]: " hyp_opt
    case $hyp_opt in
        2) HYPERVISOR="vmware" ;;
        3) HYPERVISOR="qemu" ;;
        4) HYPERVISOR="raw" ;;
        5) HYPERVISOR="rootfs" ;;
        6) HYPERVISOR="vagrant" ;;
        7) HYPERVISOR="hyperv" ;;
        *) HYPERVISOR="vbox" ;;
    esac
fi

check_dependencies

if [[ -z "$OS" ]]; then
    echo "Sistema: 1) Ubuntu 2) Debian 3) Kali Linux 4) Parrot Security"
    read -p "Opción [1]: " os_opt
    case $os_opt in
        2) OS="debian" ;;
        3) OS="kali" ;;
        4) OS="parrot" ;;
        *) OS="ubuntu" ;;
    esac
fi

# --- Selección de versión / edición según el sistema ---
if [[ "$OS" == "ubuntu" && -z "$OS_CODENAME" ]]; then
    read -p "Ubuntu versión (codename, ej: focal, jammy, noble) o 'soporte' para la actual: " ubuntu_ver
    if [[ "$ubuntu_ver" == "soporte" || -z "$ubuntu_ver" ]]; then
        OS_CODENAME="noble"
    else
        OS_CODENAME="$ubuntu_ver"
        # Verificar si la versión tiene soporte oficial
        if ! curl -s "https://changelogs.ubuntu.com/meta-release" | grep -q "$ubuntu_ver" 2>/dev/null; then
            log "ADVERTENCIA: $ubuntu_ver puede que no tenga soporte oficial." "WARNING"
        fi
    fi
elif [[ "$OS" == "debian" && -z "$OS_CODENAME" ]]; then
    echo "Versión Debian: 1) Automática (estable actual) 2) bookworm 3) bullseye 4) buster 5) testing 6) sid"
    read -p "Opción [1]: " deb_opt
    case $deb_opt in
        2) OS_CODENAME="bookworm" ;;
        3) OS_CODENAME="bullseye" ;;
        4) OS_CODENAME="buster" ;;
        5) OS_CODENAME="testing" ;;
        6) OS_CODENAME="sid" ;;
        *) OS_CODENAME="" ;; # Se autodetectará
    esac
fi

if [[ "$OS" == "kali" && -z "$DISTRO_EDITION" ]]; then
    echo "Tipo de instalación Kali: 1) Default (recomendado) 2) Large 3) Everything 4) Headless 5) Core 6) Purple (defensivo)"
    read -p "Opción [1]: " kali_ed
    case $kali_ed in
        2) DISTRO_EDITION="large" ;;
        3) DISTRO_EDITION="everything" ;;
        4) DISTRO_EDITION="headless" ;;
        5) DISTRO_EDITION="core" ;;
        6) DISTRO_EDITION="purple" ;;
        *) DISTRO_EDITION="default" ;;
    esac
fi

if [[ "$OS" == "parrot" && -z "$DISTRO_EDITION" ]]; then
    echo "Edición Parrot: 1) Security (suite de seguridad, recomendado) 2) Home 3) Core 4) Hack The Box"
    read -p "Opción [1]: " parrot_ed
    case $parrot_ed in
        2) DISTRO_EDITION="home" ;;
        3) DISTRO_EDITION="core" ;;
        4) DISTRO_EDITION="htb" ;;
        *) DISTRO_EDITION="security" ;;
    esac
fi

read -p "RAM (MB) [$VM_RAM]: " input_ram; [[ -n "$input_ram" ]] && VM_RAM="$input_ram"
read -p "Disco (ej: 50G) [$VM_DISK_SIZE]: " input_disk; [[ -n "$input_disk" ]] && VM_DISK_SIZE="$input_disk"
# Normalizar: quitar espacios y cambiar coma por punto decimal para herramientas (qemu-img, etc)
VM_DISK_SIZE=${VM_DISK_SIZE// /}
VM_DISK_SIZE=${VM_DISK_SIZE//,/.}
# Validación de tamaño de disco: si es numérico (entero o decimal), añadir 'G' por defecto
if [[ "$VM_DISK_SIZE" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
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
read -p "Paquetes APT (ej: htop,ncdu) [$OPT_APT]: " input_apt; [[ -n "$input_apt" ]] && OPT_APT="$input_apt"
read -p "Paquetes Flatpak (ej: vlc,spotify) [$OPT_FLATPAK]: " input_flatpak; [[ -n "$input_flatpak" ]] && OPT_FLATPAK="$input_flatpak"
read -p "Paquetes Snap (ej: slack,discord) [$OPT_SNAP]: " input_snap; [[ -n "$input_snap" ]] && OPT_SNAP="$input_snap"

if [[ -z "$SELECTED_MIRROR" ]]; then
    echo "Mirrors: t) Default y) Manual l) busqueda del mirror mas rapido (por pais) b) busqueda de los mirrors mas rapidos (testeo de red)"
    read -n 1 -p "Opción [l]: " mirror_choice; echo ""
    case $mirror_choice in
        t|T)
            case "$OS" in
                ubuntu) SELECTED_MIRROR="http://archive.ubuntu.com/ubuntu/" ;;
                kali) SELECTED_MIRROR="http://http.kali.org/kali/" ;;
                parrot) SELECTED_MIRROR="https://deb.parrot.sh/parrot/" ;;
                *) SELECTED_MIRROR="http://deb.debian.org/debian/" ;;
            esac
            ;;
        y|Y) read -p "URL del Mirror: " SELECTED_MIRROR ;;
        b|B) SELECTED_MIRROR=$(find_fastest_mirror_parallel "$OS") ;;
        *) SELECTED_MIRROR=$(find_mirror_by_country "$OS") ;;
    esac
fi
[[ "${SELECTED_MIRROR: -1}" != "/" ]] && SELECTED_MIRROR="${SELECTED_MIRROR}/"

read -p "¿Repositorio extrepo? (ej: vscode,signal) [ninguno]: " EXTREPOS

if [[ -z "$DESKTOP" ]]; then
    case "$OS" in
        ubuntu)
            while true; do
                echo "Escritorio Ubuntu: 1) GNOME 2) KDE 3) XFCE 4) LXDE 5) LXQt 6) Budgie 7) Edubuntu 8) Cinnamon 9) Kylin 10) MATE [aviso] 11) Unity [aviso] 12) Ubuntu Studio 13) Ninguno"
                read -p "Selecciona escritorio [13]: " desk_opt
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
                        echo "AVISO: Ubuntu MATE llega hasta 25.10 y esta en proceso de reestructuracion; es posible que Canonical elimine este sabor en el futuro. ¿Deseas continuar? (S/N)"
                        read -n 1 -p "Opción: " confirm_mate; echo ""
                        if [[ "$confirm_mate" == "s" || "$confirm_mate" == "S" ]]; then
                            DESKTOP="mate"; break
                        else
                            echo "Regresando a la selección de escritorios..."
                            continue
                        fi
                        ;;
                    11)
                        echo "AVISO: Unity no tiene soporte oficial reciente y puede fallar. ¿Deseas continuar? (S/N)"
                        read -n 1 -p "Opción: " confirm_unity; echo ""
                        if [[ "$confirm_unity" == "s" || "$confirm_unity" == "S" ]]; then
                            DESKTOP="unity"; break
                        else
                            echo "Regresando a la selección de escritorios..."
                            continue
                        fi
                        ;;
                    12) DESKTOP="ubuntustudio"; break ;;
                    *) DESKTOP="none"; break ;;
                esac
            done
            ;;
        debian)
            echo "Escritorio Debian: 1) GNOME 2) KDE 3) XFCE 4) LXDE 5) LXQt 6) Budgie 7) Cinnamon 8) MATE 9) Debian Edu (Skolelinux) 10) Ninguno"
            read -p "Selecciona escritorio [10]: " desk_opt
            case $desk_opt in
                1) DESKTOP="gnome" ;;
                2) DESKTOP="kde" ;;
                3) DESKTOP="xfce" ;;
                4) DESKTOP="lxde" ;;
                5) DESKTOP="lxqt" ;;
                6) DESKTOP="budgie" ;;
                7) DESKTOP="cinnamon" ;;
                8) DESKTOP="mate" ;;
                9) DESKTOP="skolelinux" ;;
                *) DESKTOP="none" ;;
            esac
            ;;
        kali)
            echo "Escritorio Kali: 1) XFCE 2) GNOME 3) KDE 4) MATE 5) LXDE 6) i3 7) Enlightenment 8) Ninguno (headless)"
            read -p "Selecciona escritorio [1]: " desk_opt
            case $desk_opt in
                2) DESKTOP="kali-gnome" ;;
                3) DESKTOP="kali-kde" ;;
                4) DESKTOP="kali-mate" ;;
                5) DESKTOP="kali-lxde" ;;
                6) DESKTOP="kali-i3" ;;
                7) DESKTOP="kali-e17" ;;
                8) DESKTOP="none" ;;
                *) DESKTOP="kali-xfce" ;;
            esac
            ;;
        parrot)
            echo "Escritorio Parrot: 1) KDE 2) MATE 3) XFCE 4) GNOME 5) i3 6) Ninguno (headless)"
            read -p "Selecciona escritorio [1]: " desk_opt
            case $desk_opt in
                2) DESKTOP="parrot-mate" ;;
                3) DESKTOP="parrot-xfce" ;;
                4) DESKTOP="parrot-gnome" ;;
                5) DESKTOP="parrot-i3" ;;
                6) DESKTOP="none" ;;
                *) DESKTOP="parrot-kde" ;;
            esac
            ;;
    esac
fi

# Normalizar nombres de escritorio para Kali/Parrot (permite --desktop kde ademas de kali-kde/parrot-kde)
if [[ "$OS" == "kali" && "$DESKTOP" != "none" && "$DESKTOP" != kali-* ]]; then
    DESKTOP="kali-$DESKTOP"
elif [[ "$OS" == "parrot" && "$DESKTOP" != "none" && "$DESKTOP" != parrot-* ]]; then
    DESKTOP="parrot-$DESKTOP"
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
analyze_snaps "$OPT_SNAP"

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

# --- Preparar keyring para derivados de Debian (Kali / Parrot) ---
prepare_distro_keyring() {
    BOOTSTRAP_KEYRING=""
    GUEST_KEYRING_NAME=""
    case "$OS" in
        kali)
            KEYRING_DIR=$(mktemp -d /tmp/vm_keyring.XXXXXX)
            local kr_file="$KEYRING_DIR/kali-archive-keyring.gpg"
            log "Descargando keyring oficial de Kali..." "INFO"
            if curl -fsSL "https://archive.kali.org/archive-keyring.gpg" -o "$kr_file"; then
                BOOTSTRAP_KEYRING="$kr_file"
                GUEST_KEYRING_NAME="kali-archive-keyring.gpg"
            else
                log "No se pudo descargar el keyring de Kali; se intentará sin verificación de firma." "WARNING"
            fi
            ;;
        parrot)
            KEYRING_DIR=$(mktemp -d /tmp/vm_keyring.XXXXXX)
            local kr_file="$KEYRING_DIR/parrot-archive-keyring.gpg"
            log "Descargando keyring oficial de Parrot..." "INFO"
            if ! command -v gpg &> /dev/null; then
                sudo apt-get install -y gnupg || true
            fi
            if curl -fsSL "https://deb.parrot.sh/parrot/misc/parrotsec.gpg" | gpg --dearmor > "$kr_file" 2>/dev/null; then
                BOOTSTRAP_KEYRING="$kr_file"
                GUEST_KEYRING_NAME="parrot-archive-keyring.gpg"
            else
                log "No se pudo descargar el keyring de Parrot; se intentará sin verificación de firma." "WARNING"
            fi
            ;;
    esac
}

# Un script de debootstrap por suite. Para suites sin script propio (p.ej. parrot/echo/lory)
# usamos el de 'sid' (base Debian testing/unstable sobre la que se apoyan estos derivados).
if [[ ! -e "/usr/share/debootstrap/scripts/$OS_CODENAME" ]]; then
    if [[ -e /usr/share/debootstrap/scripts/sid ]]; then
        log "Creando script de debootstrap '$OS_CODENAME' -> 'sid'..." "WARNING"
        sudo ln -sf sid "/usr/share/debootstrap/scripts/$OS_CODENAME"
    else
        log "Ajustando script de debootstrap para $OS_CODENAME (fallback)..." "WARNING"
        LATEST_SCRIPT=$(ls -v /usr/share/debootstrap/scripts/ | grep -E '^[a-z]+$' | tail -n 1)
        log "Usando script base: $LATEST_SCRIPT" "DEBUG"
        sudo ln -sf "$LATEST_SCRIPT" "/usr/share/debootstrap/scripts/$OS_CODENAME"
    fi
fi

prepare_distro_keyring

DEBOOTSTRAP_ARGS=(--arch amd64)
[[ -n "$BOOTSTRAP_KEYRING" ]] && DEBOOTSTRAP_ARGS+=(--keyring="$BOOTSTRAP_KEYRING")
case "$OS" in
    kali|parrot) DEBOOTSTRAP_ARGS+=(--components="main,contrib,non-free,non-free-firmware") ;;
esac

log "Ejecutando debootstrap (esto puede tardar varios minutos)..." "INFO"
log "Mirror: $SELECTED_MIRROR | Codename: $OS_CODENAME" "DEBUG"
sudo debootstrap "${DEBOOTSTRAP_ARGS[@]}" "$OS_CODENAME" "$MOUNT_DIR" "$SELECTED_MIRROR"

# Copiar el keyring al interior de la VM para que APT confíe en los repositorios del derivado
if [[ -n "$BOOTSTRAP_KEYRING" && -n "$GUEST_KEYRING_NAME" ]]; then
    log "Instalando keyring en el sistema invitado..." "DEBUG"
    sudo mkdir -p "$MOUNT_DIR/etc/apt/trusted.gpg.d" "$MOUNT_DIR/usr/share/keyrings"
    sudo cp "$BOOTSTRAP_KEYRING" "$MOUNT_DIR/etc/apt/trusted.gpg.d/$GUEST_KEYRING_NAME"
    sudo cp "$BOOTSTRAP_KEYRING" "$MOUNT_DIR/usr/share/keyrings/$GUEST_KEYRING_NAME"
fi

# --- CHROOT CONFIG ---
log "Preparando fase CHROOT..." "INFO"

# Determinar paquetes de herramientas de invitado y kernel (Host Logic)
G_PKG=""
if [[ "$HYPERVISOR" == "vbox" || "$HYPERVISOR" == "vagrant" ]]; then
    G_PKG="virtualbox-guest-x11 virtualbox-guest-utils"
    # Los derivados de Debian necesitan el módulo DKMS; Ubuntu ya lo trae en el kernel
    [[ "$OS" != "ubuntu" ]] && G_PKG="$G_PKG virtualbox-guest-dkms"
elif [[ "$HYPERVISOR" == "vmware" ]]; then
    G_PKG="open-vm-tools-desktop"
elif [[ "$HYPERVISOR" == "qemu" ]]; then
    G_PKG="qemu-guest-agent"
elif [[ "$HYPERVISOR" == "hyperv" ]]; then
    G_PKG="hyperv-daemons"
fi

if [[ "$OS" == "ubuntu" ]]; then
    KERNEL_PKGS="linux-image-generic grub-pc"
else
    KERNEL_PKGS="linux-image-amd64 grub-pc"
    [[ "$HYPERVISOR" == "vbox" || "$HYPERVISOR" == "vagrant" ]] && KERNEL_PKGS="$KERNEL_PKGS linux-headers-amd64 build-essential"
fi

# Metapaquetes propios de la distribución (Kali / Parrot) según edición y escritorio
DISTRO_META_PKGS=""
if [[ "$OS" == "kali" ]]; then
    case "$DISTRO_EDITION" in
        large) DISTRO_META_PKGS="kali-linux-large" ;;
        everything) DISTRO_META_PKGS="kali-linux-everything" ;;
        headless) DISTRO_META_PKGS="kali-linux-headless" ;;
        core) DISTRO_META_PKGS="kali-linux-core" ;;
        purple) DISTRO_META_PKGS="kali-linux-default kali-tools-identify kali-tools-protect kali-tools-detect kali-tools-respond kali-tools-recover kali-themes-purple" ;;
        *) DISTRO_META_PKGS="kali-linux-default" ;;
    esac
elif [[ "$OS" == "parrot" ]]; then
    PARROT_DE_PKG=""
    case "$DESKTOP" in
        parrot-kde) PARROT_DE_PKG="parrot-desktop-kde" ;;
        parrot-mate) PARROT_DE_PKG="parrot-desktop-mate" ;;
        parrot-xfce) PARROT_DE_PKG="parrot-desktop-xfce" ;;
        parrot-gnome) PARROT_DE_PKG="parrot-desktop-gnome" ;;
        parrot-i3) PARROT_DE_PKG="parrot-desktop-i3" ;;
    esac
    case "$DISTRO_EDITION" in
        core) DISTRO_META_PKGS="parrot-core" ;;
        home) DISTRO_META_PKGS="parrot-core parrot-interface parrot-interface-home $PARROT_DE_PKG" ;;
        htb) DISTRO_META_PKGS="parrot-core parrot-interface parrot-tools-full parrot-drivers $PARROT_DE_PKG" ;;
        *) DISTRO_META_PKGS="parrot-core parrot-interface parrot-interface-extra parrot-tools-full parrot-drivers $PARROT_DE_PKG" ;;
    esac
fi

cat <<CHROOT_SCRIPT > "$CONFIG_DIR/$NAME/setup.sh"
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
# No set -e here to allow custom error handling for optional packages
set +e
[[ "$VERBOSE_MODE" == "s" ]] && set -x

# --- PREVENCIÓN DE BLOQUEO POR SERVICIOS ---
# Crear policy-rc.d para evitar que los servicios intenten arrancar en chroot
# Esto evita que paquetes como ModemManager bloqueen la instalación
echo -e '#!/bin/sh\nexit 101' > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

echo "Configurando sistema (chroot phase)..."

echo "$NAME" > /etc/hostname
echo "127.0.0.1 localhost $NAME" > /etc/hosts

echo "Configurando repositorios..."
case "$OS" in
    ubuntu)
        echo "deb $SELECTED_MIRROR $OS_CODENAME main restricted universe multiverse" > /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR $OS_CODENAME-updates main restricted universe multiverse" >> /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR $OS_CODENAME-security main restricted universe multiverse" >> /etc/apt/sources.list
        ;;
    kali)
        # Kali Rolling: contrib/non-free/non-free-firmware obligatorios para las herramientas
        echo "deb $SELECTED_MIRROR kali-rolling main contrib non-free non-free-firmware" > /etc/apt/sources.list
        ;;
    parrot)
        # Parrot: suite base (parrot/echo/lory) + updates/security/backports
        echo "deb $SELECTED_MIRROR $OS_CODENAME main contrib non-free non-free-firmware" > /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR ${OS_CODENAME}-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR ${OS_CODENAME}-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR ${OS_CODENAME}-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        ;;
    *)
        # Debian: contrib, non-free y backports siempre presentes (requisito de Fast Track)
        echo "deb $SELECTED_MIRROR $OS_CODENAME main contrib non-free non-free-firmware" > /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR $OS_CODENAME-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        echo "deb $SELECTED_MIRROR $OS_CODENAME-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        echo "deb http://security.debian.org/debian-security $OS_CODENAME-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list
        ;;
esac

echo "Actualizando listas de paquetes..."
apt-get update

echo "Configurando red (Opción 1: Nativa)..."
if [[ "$OS" == "ubuntu" ]]; then
    echo "Instalando netplan.io..."
    apt-get install -y netplan.io
    RENDERER="networkd"
    if [[ "$DESKTOP" != "none" ]]; then
        echo "Detectado entorno gráfico, instalando NetworkManager..."
        apt-get install -y network-manager
        RENDERER="NetworkManager"
    fi
    mkdir -p /etc/netplan
    cat <<EOF_NET > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: $RENDERER
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
            # Usar columnas específicas para evitar capturar descripciones como IDs
            ID=\$(flatpak search --columns=application "\$p" | head -n 1 | xargs)
            if [[ -n "\$ID" && "\$ID" != "Application ID" ]]; then
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
    echo "Preparando instalación inteligente de Snaps para el primer arranque..."
    apt-get install -y snapd dbus-user-session squashfs-tools
    
    # 1. Escribimos la cabecera y la lista de snaps detectada (expandida por el host)
    cat <<EOF_FB_HEAD > /usr/local/bin/acme-first-boot.sh
#!/bin/bash
# Lista de snaps procesada por el host
SNAP_LIST="$SNAP_DATA_HOST"
# Si por alguna razón el host no pudo analizar, usamos la lista original
[[ -z "\$SNAP_LIST" ]] && SNAP_LIST="${OPT_SNAP//,/ }"
EOF_FB_HEAD

    # 2. Adjuntamos el resto de la lógica (literal, sin expansión hasta que se ejecute en la VM)
    cat <<'EOF_FB_BODY' >> /usr/local/bin/acme-first-boot.sh
log_fb() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] [SNAP-INSTALL] $1"; }

log_fb "Esperando a que snapd esté listo..."
for i in {1..30}; do
    snap wait system seed.loaded 2>/dev/null && break
    sleep 2
done

smart_snap_install() {
    local name=$1
    local initial_flags=$2
    log_fb "Procesando snap: $name..."
    
    # 1. Intento inicial
    if snap install "$name" $initial_flags 2>/dev/null; then
        log_fb "Instalado con éxito: $name ($initial_flags)"
        return 0
    fi
    
    # 2. Detección de --classic
    local error_msg
    error_msg=$(snap install "$name" 2>&1)
    if echo "$error_msg" | grep -q "classic"; then
        log_fb "Detectado requerimiento de --classic para $name. Reintentando..."
        snap install "$name" --classic && return 0
    fi

    # 3. Canales alternativos
    for channel in edge beta candidate; do
        log_fb "Probando canal --$channel para $name..."
        if snap install "$name" --channel=$channel 2>/dev/null; then
            log_fb "Instalado desde canal $channel: $name"
            return 0
        fi
        if snap install "$name" --channel=$channel --classic 2>/dev/null; then
            log_fb "Instalado desde canal $channel con --classic: $name"
            return 0
        fi
    done
    return 1
}

for item in $SNAP_LIST; do
    if [[ "$item" == *:* ]]; then
        s_name=${item%%:*}
        s_flags=${item#*:}
    else
        s_name=$item
        s_flags=""
    fi
    smart_snap_install "$s_name" "$s_flags"
done

log_fb "Proceso completado. Deshabilitando servicio."
systemctl disable acme-first-boot.service
EOF_FB_BODY

    chmod +x /usr/local/bin/acme-first-boot.sh

    cat <<EOF_SVC > /etc/systemd/system/acme-first-boot.service
[Unit]
Description=Configuración inicial de Snaps Acme
After=network-online.target snapd.service
Wants=network-online.target snapd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/acme-first-boot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF_SVC

    systemctl enable acme-first-boot.service
fi

if [[ "$DESKTOP" != "none" ]]; then
    echo "Instalando entorno de escritorio: $DESKTOP..."
    case "$OS" in
        ubuntu)
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
                unity) apt-get install -y ubuntu-unity-desktop ;;
                ubuntustudio) apt-get install -y ubuntustudio-desktop ubuntustudio-default-settings ;;
            esac
            ;;
        kali)
            case "$DESKTOP" in
                kali-gnome) apt-get install -y kali-desktop-gnome ;;
                kali-kde) apt-get install -y kali-desktop-kde ;;
                kali-xfce) apt-get install -y kali-desktop-xfce ;;
                kali-lxde) apt-get install -y kali-desktop-lxde ;;
                kali-mate) apt-get install -y kali-desktop-mate ;;
                kali-i3) apt-get install -y kali-desktop-i3 ;;
                kali-e17) apt-get install -y kali-desktop-e17 ;;
            esac
            ;;
        parrot)
            case "$DESKTOP" in
                parrot-kde) apt-get install -y parrot-desktop-kde ;;
                parrot-mate) apt-get install -y parrot-desktop-mate ;;
                parrot-xfce) apt-get install -y parrot-desktop-xfce ;;
                parrot-gnome) apt-get install -y parrot-desktop-gnome ;;
                parrot-i3) apt-get install -y parrot-desktop-i3 ;;
            esac
            ;;
        *)
            if [[ "$DESKTOP" == "skolelinux" ]]; then
                apt-get install -y education-desktop-other education-standalone
            else
                apt-get install -y task-${DESKTOP}-desktop
            fi
            ;;
    esac
fi

# --- Metapaquetes de la distribución (Kali / Parrot) ---
if [[ -n "$DISTRO_META_PKGS" ]]; then
    echo "Instalando metapaquetes de la distribución ($DISTRO_EDITION)..."
    for mp in $DISTRO_META_PKGS; do
        echo "Instalando metapaquete: \$mp"
        apt-get install -y \$mp || echo "Advertencia: no se pudo instalar \$mp"
    done
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

# Opción 1: Añadir módulos críticos y recheck para evitar errores de carga
grub-install --target=i386-pc --force --recheck --modules="part_msdos ext2 biosdisk" "\$1"
update-grub

# --- LIMPIEZA DE PREVENCIÓN ---
# Restaurar la capacidad de arrancar servicios antes de salir del chroot
rm -f /usr/sbin/policy-rc.d

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

if [[ "$HYPERVISOR" == "rootfs" ]]; then
    log "Creando tarball del rootfs..." "INFO"
    sudo tar -czf "$VM_PATH/${NAME}_rootfs.tar.gz" --exclude=./proc --exclude=./sys --exclude=./dev --exclude=./run -C "$MOUNT_DIR" .
fi

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
elif [[ "$HYPERVISOR" == "raw" ]]; then
    log "Manteniendo formato RAW..." "DEBUG"
    mv "$RAW_DISK" "$VM_PATH/${NAME}.raw"
    RAW_DISK="" # Evitar que se borre al final
elif [[ "$HYPERVISOR" == "rootfs" ]]; then
    log "RootFS ya creado. Eliminando disco RAW..." "DEBUG"
    mv "$VM_PATH/${NAME}_rootfs.tar.gz" "./${NAME}_rootfs.tar.gz"
    log "RootFS disponible en ./${NAME}_rootfs.tar.gz" "INFO"
elif [[ "$HYPERVISOR" == "hyperv" ]]; then
    log "Convirtiendo RAW a VHDX..." "DEBUG"
    qemu-img convert -f raw -O vhdx "$RAW_DISK" "$VM_PATH/${NAME}.vhdx"
elif [[ "$HYPERVISOR" == "vagrant" ]]; then
    log "Creando Vagrant Box (Libvirt)..." "DEBUG"
    qemu-img convert -f raw -O qcow2 "$RAW_DISK" "$VM_PATH/box.img"
    # Tamaño virtual en bytes -> GB
    V_SIZE=$(qemu-img info "$RAW_DISK" | grep "virtual size" | grep -oP '\(\K[0-9]+' || echo 21474836480)
    V_SIZE_GB=$(( V_SIZE / 1024 / 1024 / 1024 ))
    cat <<EOF_META > "$VM_PATH/metadata.json"
{
  "provider": "libvirt",
  "format": "qcow2",
  "virtual_size": $V_SIZE_GB
}
EOF_META
    cat <<EOF_VAGRANT > "$VM_PATH/Vagrantfile"
Vagrant.configure("2") do |config|
  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
  end
end
EOF_VAGRANT
    tar -czf "./${NAME}.box" -C "$VM_PATH" metadata.json Vagrantfile box.img
    log "Vagrant box creada en ./${NAME}.box" "INFO"
else
    log "Convirtiendo RAW a QCOW2..." "DEBUG"
    qemu-img convert -f raw -O qcow2 "$RAW_DISK" "$VM_PATH/${NAME}.qcow2"
fi
[[ -n "$RAW_DISK" ]] && rm -f "$RAW_DISK"

# --- PACKAGING ---
if [[ "$COMPRESS_FORMAT" != "none" ]]; then
    if [[ "$HYPERVISOR" == "vagrant" || "$HYPERVISOR" == "rootfs" ]]; then
        log "El formato $HYPERVISOR ya está empaquetado. Saltando compresión adicional." "INFO"
    else
        log "Empaquetando máquina virtual en formato $COMPRESS_FORMAT..." "INFO"
        case $COMPRESS_FORMAT in
            zip) zip -r "${NAME}.zip" "$VM_PATH" ;;
            rar) rar a "${NAME}.rar" "$VM_PATH" ;;
            7z) 7z a "${NAME}.7z" "$VM_PATH" && 7z t "${NAME}.7z" || { log "Error en 7z, usando respaldo ZIP" "WARNING"; zip -r "${NAME}.zip" "$VM_PATH"; } ;;
        esac
    fi
    log "Limpiando archivos temporales de construcción..." "DEBUG"
    rm -rf "$VM_PATH" "$CONFIG_DIR/$NAME"
fi

log "¡Proceso finalizado correctamente!" "INFO"
exit 0
