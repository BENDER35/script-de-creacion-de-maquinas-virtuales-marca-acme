# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

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
