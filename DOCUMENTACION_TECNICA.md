# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad**, **Programación** y **Microinformática** que deseen entender cómo orquestar la creación de entornos Linux de forma profesional y resiliente.

## 1. Arquitectura y Robustez (v1.2.5)

El script `create_vm.sh` ha evolucionado para incluir mecanismos de "autocuración" y preparación de entornos minimalistas:

*   **Inyección de Variables y Generación Dinámica:** Se utiliza la técnica de *Heredocs* para generar `setup.sh`. En la versión 1.2.5, se ha corregido un bug crítico de expansión de variables. Ahora, las listas de paquetes (`$OPT_APT`, `$G_PKG`) se inyectan correctamente desde el host al script de chroot, permitiendo una personalización real del software.
*   **Preparación del Entorno Mínimo:** Dado que `debootstrap` crea un sistema extremadamente base, el script ahora pre-crea estructuras de directorios críticas (ej. `/etc/initramfs-tools/conf.d`). Esto evita que los scripts de post-instalación de paquetes como Plymouth (temas de arranque) fallen al no encontrar rutas esperadas.
*   **Recuperación Automática:** Se implementa `dpkg --configure -a` de forma estratégica. Esto asegura que si una instalación de entorno de escritorio pesado deja paquetes a medio configurar, el sistema intente repararlos antes de proceder con el software opcional.

## 2. Gestión de Paquetes Modernos

El script integra tres de las tecnologías más relevantes para la distribución de software moderno:

### Flatpak: Aislamiento y Portabilidad
*   **Concepto:** Utiliza contenedores y *namespaces* del kernel para ejecutar aplicaciones aisladas.
*   **Implementación Técnica:** Requiere `bubblewrap` para el sandboxing. El script automatiza la resolución de IDs completos (ej: `net.lutris.Lutris`) a partir de nombres cortos.

### Snap: Servicios y Ecosistema Ubuntu
*   **Concepto:** Paquetes autogestionados por Canonical que incluyen todas sus dependencias.
*   **Desafío en Chroot:** Snap requiere el daemon `snapd`. Aunque en chroot no puede correr, el script pre-instala las dependencias necesarias (`dbus-user-session`, `squashfs-tools`) para que el sistema esté listo tras el primer reinicio.

### Extrepo: Gestión Curada (Debian)
*   **Concepto:** Herramienta oficial para habilitar repositorios de terceros de forma segura, evitando scripts `curl | sudo bash` inseguros.

## 3. Seguridad y Confianza (Ciberseguridad)

### Gestión de llaves GPG
La autenticidad de los paquetes se garantiza mediante criptografía de clave pública. El script utiliza el método moderno **Manual (signed-by)**:
1.  Se descarga la llave y se guarda en `/usr/share/keyrings/`.
2.  Se vincula la llave específicamente al archivo `.list` del repositorio.
3.  **Lección:** Esto aplica el principio de mínimo privilegio, evitando que una llave de un repositorio de terceros pueda validar paquetes del repositorio oficial del sistema.

## 4. Bibliografía y Recursos Educativos

### Sistemas Operativos y Despliegue
1.  **The Debian Administrator's Handbook:** [Guía imprescindible sobre gestión de paquetes](https://debian-handbook.info/).
2.  **Debian Wiki - debootstrap:** [Cómo construir sistemas base](https://wiki.debian.org/Debootstrap).
3.  **Linux Filesystem Hierarchy Standard (FHS):** [Estructura de directorios en Linux](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).

### Automatización y Programación
4.  **Google Shell Style Guide:** [Estándares profesionales en Bash](https://google.github.io/styleguide/shellguide.html).
5.  **Pure Bash Bible:** [Técnicas avanzadas sin dependencias externas](https://github.com/dylanaraps/pure-bash-bible).
6.  **Bash Pitfalls:** [Errores comunes y cómo evitarlos](https://mywiki.wooledge.org/BashPitfalls).

### Ciberseguridad
7.  **Apt-Key Deprecation:** [Por qué no usar apt-key y usar signed-by](https://wiki.debian.org/DebianRepository/UseThirdParty).
8.  **NIST SP 800-92:** [Guía para la gestión de logs y auditoría](https://csrc.nist.gov/publications/detail/sp/800-92/final).
9.  **OWASP Input Validation:** [Importancia de sanitizar las entradas del usuario](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html).

### Virtualización y Microinformática
10. **VBoxManage Reference:** [Automatización de VirtualBox desde CLI](https://www.virtualbox.org/manual/ch08.html).
11. **QEMU Disk Images:** [Formatos de disco (RAW, QCOW2, VMDK)](https://www.qemu.org/docs/master/system/images.html).
12. **CompTIA A+ / SMR Resources:** [Conceptos básicos de montaje y configuración de SO](https://www.comptia.org/certifications/a).
