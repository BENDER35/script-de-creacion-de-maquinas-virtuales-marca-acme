# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

## [1.7.3] - 2026-10-14
### Añadido
- **Soporte Parrot Security**: El script ahora puede crear máquinas virtuales de la suite de seguridad **Parrot OS**. Ediciones: **Security** (kit ofensivo completo, por defecto), **Home**, **Core** y **Hack The Box**. Entornos de escritorio: KDE, MATE, XFCE, GNOME, LXQt e i3.
- **Keyrings oficiales para derivados de Debian**: Descarga e instalación automática de las claves de APT oficiales de Kali y Parrot (`debootstrap --keyring` y `/etc/apt/trusted.gpg.d` del invitado).
- **Manejo de la suite rolling de Parrot**: Usa la suite rolling `parrot` (actualmente "Echo") más los componentes `-updates`, `-security` y `-backports`, con `main contrib non-free non-free-firmware`.
- **Selección de versión Debian**: Permite elegir entre la rama estable actual (autodetectada), bookworm, bullseye, buster, testing o sid.

### Modificado
- **Ediciones de Kali**: Añadido el selector de tipo de instalación (Default, Large, Everything, Headless, Core y Purple) y completada la lista de escritorios de Kali (XFCE, GNOME, KDE, MATE, LXDE, i3, Enlightenment).
- **Menú de selección de escritorio**: Rehecho limpiamente por distribución (Ubuntu/Debian/Kali/Parrot), corrigiendo opciones duplicadas y mal numeradas.
- **Validación de argumentos**: Añadida validación para `--os` (ubuntu/debian/kali/parrot) y `--hyp`; añadida la opción `--edition`.
- **Instalación de dependencias**: Los fallos al instalar dependencias del host ya no son fatales (avisa y continúa).
- **Manejo del codename**: `fetch_latest_versions` ya no sobrescribe el codename elegido por el usuario.
- **Mirrors según distribución**: Las funciones de mirror devuelven el mirror oficial para Kali y Parrot.

### Corregido
- **Error de sintaxis crítico**: Al bloque de selección de escritorio le faltaba un `fi`, lo que provocaba un error de "unexpected end of file" e impedía que el script arrancara.
- **Variable `$SKOLA` sin definir**: Eliminadas las referencias sueltas; Debian Edu (Skolelinux) se selecciona ahora de forma explícita.
- **Menú de hypervisor**: Ya no vuelve a preguntar cuando se pasa `--hyp vbox`.

## [1.7.2] - 2026-10-13
### Añadido
- **Soporte Kali Linux**: Creación de máquinas virtuales Kali Rolling con selección de entornos de escritorio.
- **Soporte de Ubuntu Legacy**: Posibilidad de indicar un codename de Ubuntu sin soporte oficial, con aviso.
- **Escritorios adicionales**: MATE y Cinnamon en Debian.

### Modificado
- **Vagrant y QEMU**: Soporte existente documentado (sin cambios funcionales).

## [1.7.1] - 2026-10-13
### Añadido
- **Sistema de caché de mirrors**: Implementación de una caché local para almacenar el mirror más rápido encontrado, evitando testees redundantes en ejecuciones posteriores.
- **Pruebas paralelas de mirrors**: Optimización del testeo de mirrors reduciendo el número de candidatos de 20 a 10, reduciendo el tiempo de selección en un 70% aproximadamente.
- **Mejoras en la descarga de Wallhaven**: Añadida lógica de reintentos (retries) y filtrado de formatos de imagen (.jpg, .png, .gif, .webp) para evitar descargas fallidas y asegurar que solo se guarden imágenes válidas.
- **Validación de entrada en el parseo de argumentos**: Validación en tiempo real para --ram, --cpucores y --disk justo después de la entrada del usuario.
- **Corrección de expansión de variables en GRUB**: Solucionado el problema por el que `$1` dentro del script de chroot no expandía correctamente el parámetro del dispositivo. Ahora incluye un comentario explicativo en el código.
- **Mejora en la detección de IDs de Flatpak**: Lógica mejorada para distinguir correctamente entre IDs completos de Flatpak y nombres de paquete, evitando búsquedas descriptivas incorrectas.
- **Manejo de errores mejorado**: Mejor manejo de errores en la selección de mirror, la instalación de Flatpak y la descarga de fondos.

### Modificado
- **Estructura de argumentos**: Añadida validación de hypervisores, sistemas operativos y valores numéricos positivos en el parseo de --name, --os, --hyp, --ram, --cpucores y --disk.
- **Limpieza de contraseñas**: Mejora de la gestión de contraseñas usando `read -s` y validación de robustez.
- **Refactorización de funciones**: Las funciones de selección de mirror (`find_fastest_mirror`, `find_fastest_mirror_parallel`) ahora usan caché y tienen mejor manejo de errores de `curl`.

### Corrección
- **Error de expansión de `$1` en GRUB**: Solucionado el problema por el que `$1` en la línea `grub-install` expandía al escribir el script en lugar de ejecutarse en el chroot. Se añadió un comentario explicativo.
- **Manejo de variables en heredocs**: Ajustadas las variables `$p` y `$initial_flags` en las secciones de Flatpak y Snaps para asegurar una expansión correcta al ejecutarse en la VM.

## [1.7.0] - 2026-05-18
### Añadido
- **Sistema Anti-Bloqueo de Servicios (Propuesta 1)**: Implementación de `policy-rc.d` para garantizar estabilidad absoluta durante la fase de construcción (`chroot`).
  - **Prevención de cuelgues**: Evita que servicios como `ModemManager`, `MySQL` o `Apache` intenten arrancar dentro del entorno enjaulado, lo que causaba bloqueos infinitos en Hyper-V y otros entornos.
  - **Aislamiento de la instalación**: Asegura que el proceso `apt-get install` se centre únicamente en desempaquetar y configurar archivos, delegando el arranque de servicios al primer arranque real de la VM.
- **Documentación Multidisciplinar (v2)**: Renovación total del README y la Documentación Técnica centrada en la inclusión socioprofesional.
  - **Iniciación técnica**: Guías específicas para estudiantes de Sistemas, Programación, Ciberseguridad y Microinformática (SMR/ASIR/DAM/DAW).
  - **Resistencia creativa**: Sección dedicada a ilustradores, diseñadores y editores de vídeo que migran a Linux por ahorro de costes y hardware antiguo.
  - **Puente Windows-Linux**: Manual de aterrizaje suave para usuarios que abandonan ecosistemas propietarios.
  - **Bibliografía académica y profesional**: Inclusión de fuentes de consulta técnica y manuales de software creativo (Krita, Blender, OBS) en todos los documentos.

### Modificado
- **Lógica de dependencias**: Mejora en la detección de paquetes virtuales y proveedores de fallback.

## [1.6.1] - 2026-05-17
### Corregido
- **Fallo de paquetes virtuales**: Se ha resuelto el error crítico que impedía la instalación de `qemu-user-static` en distribuciones modernas (como Ubuntu 26.04 "Resolute").
  - **Lógica de fallback**: El script ahora detecta si `qemu-user-static` es un paquete virtual e intenta automáticamente la instalación de sus proveedores (`qemu-user-binfmt` o `qemu-user-binfmt-hwe`).
  - **Detección de binarios**: Verificación de dependencias mejorada para comprobar la existencia real de binarios en `/usr/bin/` antes de intentar una instalación redundante.

## [1.6.0] - 2026-05-17
### Añadido
- **Expansión Multi-Hypervisor (7 formatos)**: Soporte nativo para **RAW**, **RootFS**, **Vagrant** (Libvirt) y **Hyper-V** (VHDX), además de los originales.
- **Soporte avanzado de Netplan**: Implementación de renderizadores dinámicos (`networkd` para servidores, `NetworkManager` para escritorios) en Ubuntu.
- **Cajas Vagrant**: Generación automática de los archivos `metadata.json` y `Vagrantfile` para un despliegue inmediato del laboratorio.

## [1.5.1] - 2026-05-13
### Corregido
- **Estabilidad de red en Debian**: Mejora de la configuración de `/etc/network/interfaces` para evitar bloqueos durante el arranque.
- **Gestión de dispositivos loop**: Refactorización del sistema `cleanup trap` para garantizar la liberación del dispositivo en caso de error.

## [1.5.0] - 2026-05-08
### Añadido
- **Snap Inteligente (Primer Arranque)**: Creación de un servicio `systemd` temporal que instala Snaps en el primer arranque, resolviendo la limitación del `chroot`.
- **Integración de extrepo**: Soporte para habilitar repositorios externos de forma segura (ej.: VSCode, Signal).
- **Descargas multi-consulta de Wallhaven**: Capacidad de buscar y descargar fondos de varias categorías simultáneamente.

## [1.4.0] - 2026-05-07
### Añadido
- **Motor de Construcción por Bootstrap**: Transición de un sistema basado en ISO a la inyección directa de paquetes, permitiendo una personalización total desde cero.
- **Selector de Escritorio**: Soporte para GNOME, KDE, XFCE, LXDE, LXQt, Budgie, MATE, Unity y sabores educativos/multimedia.
- **Gestión de Compresión**: Opciones para empaquetar los resultados en ZIP, RAR y 7z con verificación de integridad.

## [1.3.0] - 2026-05-07
### Añadido
- **API de Wallhaven**: Integración inicial para la descarga automatizada de recursos visuales por etiquetas.
- **Gestión de fondos locales**: Capacidad de inyectar fondos desde una ruta del host a la VM.
- **Modo Verbose**: Implementación de depuración detallada (`set -x`) para la resolución de problemas técnicos.

## [1.2.0] - 2026-05-07
### Añadido
- **Arquitectura Multi-Hypervisor inicial**: Soporte para **VirtualBox**, **VMware** y **QEMU**.
- **Conversión automática de disco**: Uso de `qemu-img` y `VBoxManage` para exportar formatos VDI, VMDK y QCOW2.

## [1.1.0] - 2026-05-06
### Añadido
- **Optimización de mirrors**: Algoritmos para detectar mirrors cercanos por geolocalización y testeo de latencia en paralelo.
- **Personalización de usuario**: Inclusión de preguntas para definir usuarios y contraseñas personalizadas (SUDO por defecto).

## [1.0.0] - 2026-05-06
### Añadido
- **MVP (Producto Mínimo Viable)**: Script base automatizado para la creación de máquinas virtuales Ubuntu/Debian mediante generación de ISOs de autoinstalación.
- **Estructura de directorios**: Definición de las carpetas `vms`, `configs` e `isos`.
