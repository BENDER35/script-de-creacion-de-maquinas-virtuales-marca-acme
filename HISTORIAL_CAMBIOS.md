# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

## [1.3.0] - 2026-05-11
### Añadido
- **Interfaz de Línea de Comandos (CLI)**: Implementación de parámetros robustos (`--name`, `--os`, `--desktop`, `--flatpak`, etc.) para permitir ejecuciones no interactivas.
- **Enfoque Creativo**: Expansión de la documentación para Artistas Digitales, Ilustradores y Streamers, destacando las ventajas del kernel de baja latencia de Ubuntu Studio.
- **Guía de Migración**: Nuevas secciones educativas para facilitar el paso de Windows a Linux en perfiles creativos y técnicos.

### Corregido
- **Resolución de Flatpaks**: Sustitución de la lógica de búsqueda basada en `awk` por `flatpak search --columns=application`. Ahora el script identifica correctamente los IDs de aplicaciones (ej. `org.videolan.VLC`) incluso con nombres cortos o ambiguos.

### Modificado
- **Documentación Pedagógica**: Reestructuración de README y Documentación Técnica con un enfoque integral para Sistemas, Programación, Ciberseguridad, Microinformática y Creación Digital.
- **Bibliografía Multidisciplinar**: Inclusión de recursos especializados para flujos de trabajo creativos y transición desde ecosistemas propietarios.

## [1.2.9] - 2026-05-11
### Añadido
- **Sabor Multimedia**: Incorporación de la opción **KDE(studio)** para Ubuntu, facilitando la creación de entornos de producción multimedia.
- **Configuración Automática**: Instalación de `ubuntustudio-desktop` y `ubuntustudio-default-settings` para asegurar una experiencia de usuario optimizada desde el primer arranque.
- **Bibliografía Educativa**: Expansión masiva de recursos para perfiles de Sistemas, Programación, Ciberseguridad, Microinformática e interesados en la transición desde Windows.

## [1.2.8] - 2026-05-11
### Añadido
- **Almacenamiento Avanzado**: Incorporación de una unidad óptica virtual vacía en el controlador SATA (puerto 1) para VirtualBox. Esto facilita el montaje posterior de ISOs de herramientas o datos sin reconfigurar la VM.
- **Guía de Transición**: Nueva sección en la documentación orientada a usuarios que migran de Windows a Linux.

### Modificado
- **Expansión Documental**: Reestructuración completa de README y Documentación Técnica para cubrir las necesidades de alumnos de Sistemas (SMR/ASIR), Ciberseguridad, Programación y Microinformática.
- **Bibliografía Ampliada**: Inclusión de recursos específicos para la transición desde Windows y aprendizaje profundo de sistemas.

## [1.2.7] - 2026-05-11
### Corregido
- **Fallo Crítico de Arranque (Blinking Cursor)**: Se ha corregido un error de escape en el bloque Heredoc que impedía que `grub-install` recibiera el dispositivo correcto. Ahora las variables posicionales (`$1`) se evalúan correctamente dentro del entorno `chroot`.
- **Preconfiguración de Debconf**: La selección automática del dispositivo para `grub-pc` ahora se realiza de forma efectiva, evitando bloqueos interactivos durante la instalación del kernel.

### Modificado
- **Refuerzo de Documentación**: Actualización exhaustiva del README y la Documentación Técnica con un enfoque renovado en la formación profesional (Sistemas, Programación y Ciberseguridad).

## [1.2.6] - 2026-05-10
### Añadido
- **Conectividad Automática**: Implementación de la "Opción 1" de red. Configuración nativa de DHCP mediante Netplan (Ubuntu) e `/etc/network/interfaces` (Debian).
- **Optimización de Hardware Virtual**: Cambio del tipo de adaptador de red a `virtio` en VirtualBox para maximizar el rendimiento y la detección en sistemas modernos.

### Corregido
- **Falta de Internet**: Solucionado el problema donde las máquinas arrancaban sin interfaz de red activa por ausencia de configuración en el sistema base.

### Modificado
- **Reversión de APT**: Se ha revertido el cambio en la expansión de variables para paquetes APT y Guest Tools, volviendo al comportamiento anterior a la v1.2.5 para mantener la compatibilidad con flujos de trabajo específicos.

## [1.2.5] - 2026-05-10
### Añadido
- **Robustez en Chroot**: Creación preventiva del directorio `/etc/initramfs-tools/conf.d` para evitar fallos de post-instalación en paquetes que gestionan el arranque (como Plymouth).
- **Recuperación Automática**: Implementación de `dpkg --configure -a` antes de la instalación de software opcional para asegurar la consistencia del sistema.
- **Enfoque Educativo**: Reestructuración del README y documentación técnica orientada a cursos de Sistemas, Ciberseguridad, Programación y Microinformática.
- **Bibliografía Especializada**: Inclusión de recursos de aprendizaje avanzados sobre administración de sistemas y automatización.

### Corregido
- **Bug de Expansión Crítico**: Corrección de escapes en el Heredoc de `setup.sh` que impedían la instalación de paquetes APT opcionales (`$OPT_APT`) y Guest Tools (`$G_PKG`).
- **Limpieza de Sistema**: Adición de pasos finales de limpieza para reducir el tamaño de las imágenes generadas.

## [1.2.0] - 2026-05-09
### Añadido
- **Personalización de Hardware**: Control total sobre RAM, núcleos de CPU y tamaño de disco.
- **Nuevos Sabores de Ubuntu**: Soporte para Edubuntu, Cinnamon y Kylin.
- **Benchmarking de Mirrors**: Selección inteligente del servidor más rápido mediante pruebas de red paralelas.
- **Aislamiento en Software**: Inclusión de `bubblewrap` para Flatpak y soporte mejorado para Snap.

## [1.1.0] - 2026-05-08
### Añadido
- **Soporte Debian**: Integración de Debian Trixie mediante el repositorio Fast Track.
- **Seguridad GPG**: Implementación de importación de llaves vía keyservers y uso de `signed-by`.
- **Sistema de Logging**: Captura total de stdout/stderr en informes fechados.

## [1.0.0] - 2026-05-06
### Añadido
- **Versión Inicial**: Soporte base para Ubuntu mediante `debootstrap` y creación de discos RAW/VDI.
- **Automatización**: Generación de CIDATA y configuración automática de red/usuario.
