# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

## [1.7.1] - 2026-10-13
### Añadido
- **Sistema de Caché de Mirrors**: Implementación de caché local para almacenar el mirror más rápido encontrado, evitando testees redundantes en ejecuciones subsiguientes.
- **Pruebas Paralelas de Mirrors**: Optimización del testeo de mirrors reduciendo el número de candidates de 20 a 10, reduciendo el tiempo de selección en aproximadamente un 70%.
- **Mejoras en Descargas de Wallhaven**: Agregado de lógica de reintentos (retries) y filtrado por extensiones de imagen (.jpg, .png, .gif, .webp) para evitar descargas fallidas y asegurar solo archivos de imagen válidos.
- **Validación de Entrada en Parsing de Argumentos**: Validación en tiempo real para --ram, --cpucores y --disk inmediatamente después de la entrada del usuario.
- **Corrección de Expansión de Variables en GRUB**: Solucionado el problema donde `$1` dentro del script chroot no expandía correctamente el dispositivo. Ahora incluye una nota explicativa.
- **Mejora en la Detección de IDs de Flatpak**: Mejorada la lógica para distinguir entre IDs completos de Flatpak y nombres de paquetes, evitando búsquedas descriptivas incorrectas.
- **Manejo de Errores Mejorado**: Mejor manejo de errores en la selección de mirrors, instalación de Flatpak y descargas de wallpapers.

### Modificado
- **Estructura de Argumentos**: Agregada validación de hipervisores, sistemas operativos y valores numéricos positivos en el parsing de argumentos `--name`, `--os`, `--hyp`, `--ram`, `--cpucores` y `--disk`.
- **Limpieza de Contraseñas**: Mejorada la gestión de la contraseña de usuario mediante `read -s` y validación de fortaleza.
- **Refactorización de Funciones**: Las funciones de selección de mirrors (`find_fastest_mirror`, `find_fastest_mirror_parallel`) ahora utilizan caché y tienen mejor manejo de errores de `curl`.

### Corrección
- **Error de Expansión de `$1` en GRUB**: Se corrigió el problema donde `$1` en la línea de `grub-install` se expandía al momento de escribir el script en lugar de ejecutarse en chroot. Se añadió documentación en comentario.
- **Manejo de Variables en Scripts Heredoc**: Se ajustaron las variables `$p` y `$initial_flags` en las secciones de Flatpak y Snaps para asegurar la expansión correcta al ejecutarse en la VM.

## [1.7.0] - 2026-05-18
### Añadido
- **Sistema Anti-Bloqueo de Servicios (Propuesta 1)**: Implementación de `policy-rc.d` para garantizar la estabilidad absoluta durante la fase de construcción (`chroot`).
  - **Prevención de Cuelgues**: Evita que servicios como `ModemManager`, `MySQL` o `Apache` intenten arrancar dentro del entorno enjaulado, lo que causaba bloqueos infinitos en Hyper-V y otros entornos.
  - **Aislamiento de Instalación**: Asegura que el proceso de `apt-get install` se centre únicamente en desempaquetar y configurar archivos, delegando el arranque de servicios al primer inicio real de la VM.
- **Documentación Multidisciplinar (v2)**: Renovación total del README y la Documentación Técnica enfocada en la inclusión socioprofesional.
  - **Iniciación Técnica**: Guías específicas para estudiantes de Sistemas, Programación, Ciberseguridad y Microinformática (SMR/ASIR/DAM/DAW).
  - **Resistencia Creativa**: Sección dedicada a ilustradores, diseñadores y editores de vídeo que migran a Linux por ahorro de costes y hardware antiguo.
  - **Puente Windows-Linux**: Manual de aterrizaje suave para usuarios que abandonan ecosistemas propietarios.
  - **Bibliografía Académica y Profesional**: Inclusión de fuentes de consulta técnica y manuales de software creativo (Krita, Blender, OBS) en todos los documentos.

### Modificado
- **Lógica de Dependencias**: Mejora en la detección de paquetes virtuales y proveedores de fallback.

## [1.6.1] - 2026-05-17
### Corregido
- **Fallo de Dependencias (Virtual Packages)**: Se ha solucionado el error crítico que impedía la instalación de `qemu-user-static` en distribuciones modernas (como Ubuntu 26.04 "Resolute").
  - **Lógica de Fallback**: El script ahora detecta si `qemu-user-static` es un paquete virtual e intenta automáticamente la instalación de sus proveedores (`qemu-user-binfmt` o `qemu-user-binfmt-hwe`).
  - **Detección por Binarios**: Se ha mejorado la verificación de dependencias para comprobar la existencia real de los binarios en `/usr/bin/` antes de intentar una instalación redundante.

## [1.6.0] - 2026-05-17
### Añadido
- **Expansión Multi-Hypervisor (7 formatos)**: Soporte nativo para **RAW**, **RootFS**, **Vagrant** (Libvirt) e **Hyper-V** (VHDX), además de los originales.
- **Soporte Netplan Avanzado**: Implementación de renderizadores dinámicos (`networkd` para servidores, `NetworkManager` para escritorios) en Ubuntu.
- **Vagrant Boxes**: Generación automática de archivos `metadata.json` y `Vagrantfile` para el despliegue inmediato de laboratorios.

## [1.5.1] - 2026-05-13
### Corregido
- **Estabilidad de Red en Debian**: Mejora de la configuración de `/etc/network/interfaces` para evitar bloqueos durante el arranque.
- **Gestión de Dispositivos Loop**: Refactorización del sistema de limpieza (`cleanup trap`) para asegurar la liberación de dispositivos en caso de error.

## [1.5.0] - 2026-05-08
### Añadido
- **Sistema Smart Snap (First Boot)**: Creación de un servicio `systemd` temporal que instala Snaps en el primer arranque, solucionando la limitación de `chroot`.
- **Integración con extrepo**: Soporte para habilitar repositorios externos de forma segura (ej: VSCode, Signal).
- **Descargas Wallhaven Multi-Query**: Capacidad de buscar y descargar fondos de pantalla de múltiples categorías simultáneamente.

## [1.4.0] - 2026-05-07
### Añadido
- **Motor de Construcción debootstrap**: Transición de un sistema basado en ISO a la inyección directa de paquetes, permitiendo personalización total desde cero.
- **Selector de Escritorios**: Soporte para GNOME, KDE, XFCE, LXDE, LXQt, Budgie, MATE, Unity y sabores educativos/multimedia.
- **Gestión de Compresión**: Opciones para empaquetar resultados en ZIP, RAR y 7z con verificación de integridad.

## [1.3.0] - 2026-05-07
### Añadido
- **API de Wallhaven**: Integración inicial para la descarga automatizada de recursos visuales basados en etiquetas.
- **Gestión de Fondos Locales**: Capacidad de inyectar fondos de pantalla desde una ruta del host a la VM.
- **Modo Verbose**: Implementación de depuración detallada (`set -x`) para resolución de problemas técnicos.

## [1.2.0] - 2026-05-07
### Añadido
- **Arquitectura Multi-Hypervisor Inicial**: Soporte para **VirtualBox**, **VMware** y **QEMU**.
- **Conversión Automática de Disco**: Uso de `qemu-img` y `VBoxManage` para exportar formatos VDI, VMDK y QCOW2.

## [1.1.0] - 2026-05-06
### Añadido
- **Optimización de Mirrors**: Algoritmos de detección de espejos más cercanos por geolocalización y testeo de latencia paralelo.
- **Personalización de Usuario**: Inclusión de prompts para definir usuarios y contraseñas personalizados (SUDO por defecto).

## [1.0.0] - 2026-05-06
### Añadido
- **MVP (Producto Mínimo Viable)**: Script base automatizado para la creación de máquinas virtuales Ubuntu/Debian mediante generación de ISOs de autoinstalación.
- **Estructura de Directorios**: Definición de carpetas `vms`, `configs` e `isos`.