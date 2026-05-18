# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

## [1.7.0] - 2026-05-18
### Añadido
- **Sistema Anti-Bloqueo de Servicios (Propuesta 1)**: Implementación de `policy-rc.d` para garantizar la estabilidad absoluta durante la fase de construcción (`chroot`).
  - **Prevención de Cuelgues**: Evita que servicios como `ModemManager`, `MySQL` o `Apache` intenten arrancar dentro del entorno enjaulado, lo que causaba bloqueos infinitos en Hyper-V y otros entornos.
  - **Aislamiento de Instalación**: Asegura que el proceso de `apt-get install` se centre únicamente en desempaquetar y configurar archivos, delegando el arranque de servicios al primer inicio real de la VM.
### Modificado
- **Documentación Multidisciplinar (v2)**: Renovación total del README y la Documentación Técnica enfocada en la inclusión socioprofesional.
  - **Iniciación Técnica**: Guías específicas para estudiantes de Sistemas, Programación, Ciberseguridad y Microinformática (SMR/ASIR/DAM/DAW).
  - **Resistencia Creativa**: Sección dedicada a ilustradores, diseñadores y editores de vídeo que migran a Linux por ahorro de costes y hardware antiguo.
  - **Puente Windows-Linux**: Manual de aterrizaje suave para usuarios que abandonan ecosistemas propietarios.
  - **Bibliografía Académica y Profesional**: Inclusión de fuentes de consulta técnica y manuales de software creativo (Krita, Blender, OBS) en todos los documentos.

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
