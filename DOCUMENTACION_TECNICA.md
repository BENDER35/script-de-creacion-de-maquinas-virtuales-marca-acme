# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad**, **Programación** y **Microinformática**, así como para **migrantes de Windows** y **profesionales creativos** que buscan una alternativa potente y económica.

## 1. Arquitectura y Robustez (v1.4.0)

El script `create_vm.sh` ha evolucionado para incluir mecanismos de "autocuración" y preparación de entornos avanzados:

*   **Arranque Garantizado (GRUB):** Se ha resuelto el error crítico `normal.mod not found` que afectaba a las instalaciones con entorno gráfico. La solución técnica implementada incluye:
    1.  **Reordenación de la fase Chroot:** La instalación del kernel y GRUB ahora ocurre *después* de la instalación de todos los paquetes de escritorio y software opcional. Esto evita que los triggers de `apt` (como los de Plymouth o los drivers de video) invaliden la configuración del cargador de arranque.
    2.  **Módulos Estáticos:** El comando `grub-install` ahora incluye explícitamente los módulos `ext2`, `part_msdos` y `biosdisk`, asegurando que el cargador pueda leer la partición de sistema independientemente de la detección automática del host.
    3.  **Saneamiento con --recheck:** Se utiliza el parámetro `--recheck` para regenerar el mapa de dispositivos, eliminando inconsistencias entre el dispositivo `loop` del host y el disco virtual.

*   **Gestión Dinámica de Red (NetworkManager):** El script detecta si se ha seleccionado un escritorio gráfico. De ser así, configura Netplan para usar `NetworkManager` como renderizador, asegurando que el icono de red y la gestión desde la UI funcionen correctamente. En modo servidor, mantiene `networkd` para mayor ligereza.

*   **Soporte Creativo Profesional:** Ubuntu Studio se ofrece con un kernel de baja latencia (low-latency), esencial para profesionales del audio y streaming que necesitan respuesta en tiempo real.

## 2. Gestión de Paquetes y Sandboxing

*   **Flatpak con Búsqueda Inteligente:** El script no solo instala paquetes Flatpak, sino que utiliza `flatpak search` para resolver IDs de aplicaciones. Esto facilita a los artistas encontrar herramientas como `Krita` o `Blender` sin conocer el ID exacto (ej. `org.kde.krita`).
*   **Aislamiento:** La inclusión de `bubblewrap` asegura que las aplicaciones instaladas vía Flatpak operen en un entorno seguro y aislado del núcleo del sistema.

## 3. Guía de Orientación por Perfiles

### A. Estudiantes de IT (Sistemas, Redes, Ciberseguridad)
*   **Microinformática:** El script automatiza la creación de discos `.vdi` y `.vmdk`. La inclusión de una unidad óptica vacía permite practicar el arranque desde ISOs externas para mantenimiento de sistemas.
*   **Ciberseguridad:** Crear máquinas "limpias" mediante `debootstrap` minimiza la superficie de ataque. Es la base para construir "honeypots" o entornos de análisis forense.
*   **Programación:** El script es un ejemplo avanzado de automatización. El uso de `Heredocs` para generar el script `setup.sh` dinámicamente es una técnica fundamental en DevOps y despliegue de infraestructura.

### B. Migrantes desde Windows (Guía de Supervivencia)
*   **Jerarquía de Archivos:** Olvida el concepto de letras de unidad (`C:`, `D:`). En Linux, todo es un archivo que cuelga de la raíz `/`.
*   **Seguridad Activa:** La arquitectura de permisos de Linux impide que un virus afecte al sistema completo sin intervención del administrador (`sudo`).
*   **Equivalencias de Software:**
    *   **Office -> LibreOffice:** Compatibilidad total con formatos `.docx` y `.xlsx`.
    *   **Explorer -> Nautilus/Thunar:** Administradores de archivos potentes y personalizables.

### C. Creativos: Diseño, Vídeo y Streaming (Economía y Rendimiento)
*   **Rendimiento en Hardware Modesto:** Linux utiliza menos RAM y ciclos de CPU para el sistema base, dejando más recursos libres para el renderizado de vídeo o la pintura digital.
*   **Herramientas de Nivel Profesional:**
    *   **Krita:** Supera a Photoshop en herramientas específicas para ilustración y animación 2D.
    *   **DaVinci Resolve:** El mismo software usado en Hollywood para corrección de color está disponible de forma nativa en Linux.
    *   **OBS Studio:** Al correr sobre un sistema más ligero, permite tasas de bits (bitrate) más estables para streamers.

## 4. Bibliografía y Recursos Educativos

### Sistemas Operativos y Despliegue (SMR/ASIR)
1.  **The Debian Administrator's Handbook:** [La biblia sobre gestión de sistemas Debian](https://debian-handbook.info/).
2.  **Debian Wiki - debootstrap:** [Manual de construcción de sistemas base](https://wiki.debian.org/Debootstrap).
3.  **Linux Filesystem Hierarchy Standard (FHS):** [Referencia oficial de directorios](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).

### Automatización y Programación
4.  **Google Shell Style Guide:** [Estándares de la industria para scripts en Bash](https://google.github.io/styleguide/shellguide.html).
5.  **Bash Pitfalls:** [Guía para evitar errores comunes en scripting](https://mywiki.wooledge.org/BashPitfalls).
6.  **Full Stack Open - Docker/Linux:** [Despliegue moderno](https://fullstackopen.com/es/).

### Ciberseguridad y Aislamiento
7.  **Flatpak Documentation:** [Seguridad y sandboxing](https://docs.flatpak.org/).
8.  **NIST Cybersecurity Framework:** [Estándares internacionales de seguridad](https://www.nist.gov/cyberframework).
9.  **TryHackMe - Linux Fundamentals:** [Aprendizaje interactivo](https://tryhackme.com/module/linux-fundamentals).

### Creación Digital, Diseño y Streaming
10. **Ubuntu Studio Manual:** [Configuración para multimedia profesional](https://ubuntustudio.org/tour/).
11. **Krita Foundation:** [Documentación oficial de ilustración](https://docs.krita.org/).
12. **Blender Manual:** [Guía completa de 3D y VFX](https://docs.blender.org/).
13. **OBS Studio Wiki:** [Configuración avanzada de streaming](https://obsproject.com/wiki/).

### Transición Windows -> Linux (Migración)
14. **Linux Journey:** [Curso visual para principiantes](https://linuxjourney.com/).
15. **AlternativeTo:** [Buscador de software libre equivalente](https://alternativeto.net/).
16. **DistroSea:** [Pruebas de sistemas en la nube](https://distrosea.com/).
