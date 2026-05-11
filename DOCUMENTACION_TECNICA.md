# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad**, **Programación** y **Microinformática** que deseen entender cómo orquestar la creación de entornos Linux de forma profesional y resiliente.

## 1. Arquitectura y Robustez (v1.2.8)

El script `create_vm.sh` ha evolucionado para incluir mecanismos de "autocuración" y preparación de entornos avanzados:

*   **Configuración de Almacenamiento SATA:** Se ha estandarizado el uso de controladores SATA para VirtualBox. Además del disco duro principal (`.vdi`), el script adjunta automáticamente una **unidad óptica virtual vacía** en el puerto 1. Esto permite a los estudiantes de microinformática practicar el montaje de imágenes ISO (como GParted o discos de rescate) sin tener que modificar la configuración de hardware de la VM.
*   **Instalación Silenciosa de Bootloaders:** Se utiliza inyección de variables en el entorno `chroot` para asegurar que GRUB se instale en el MBR. El uso de escapes en *Heredocs* (`\$1`) es una competencia clave para desarrolladores de scripts de automatización.
*   **Red Nativa e Interoperabilidad:** Configuración DHCP mediante Netplan (Ubuntu) e `ifupdown` (Debian). El uso de drivers **VirtIO** asegura que las prácticas de redes y ciberseguridad se realicen con el máximo rendimiento de red posible.
*   **Preparación del Entorno Mínimo:** Se pre-crean estructuras críticas como `/etc/initramfs-tools/conf.d`, evitando errores comunes en sistemas Debian/Ubuntu modernos que utilizan Plymouth para el arranque gráfico.
*   **Recuperación Automática:** El script incluye `dpkg --configure -a` para garantizar la consistencia del sistema antes de instalar entornos de escritorio (GNOME, KDE, XFCE) o software opcional.

## 2. Gestión de Paquetes Modernos

El script integra tres tecnologías fundamentales para la distribución de software:

### Flatpak: Aislamiento y Sandboxing
*   **Relevancia en Ciberseguridad:** Permite ejecutar aplicaciones con privilegios limitados. Requiere `bubblewrap` para el aislamiento de procesos. El script automatiza la resolución de nombres de paquetes a IDs de Flathub.

### Snap: Contenedores de Aplicación
*   **Relevancia en Programación:** Facilita tener versiones actualizadas de herramientas de desarrollo (VS Code, Go, Python) aisladas del sistema base. El script gestiona las dependencias de `snapd` en entornos chroot.

### Extrepo: Repositorios Curados
*   **Relevancia en Sistemas:** Permite habilitar repositorios oficiales de terceros (como el de Microsoft para VS Code o el de Signal) sin comprometer la integridad del sistema mediante el uso de llaves GPG gestionadas.

## 3. ¿Vienes de Windows? Guía de Orientación

Para aquellos que están dando sus primeros pasos fuera del ecosistema Windows, este script es la puerta de entrada perfecta:

*   **Terminal vs. GUI:** En Linux, la terminal no es un "último recurso" como el CMD, sino una herramienta de precisión. Este script demuestra cómo una tarea compleja (instalar un SO) se puede resumir en líneas de comandos.
*   **Estructura de Directorios:** Olvida las letras de unidad (C:, D:). En Linux todo cuelga de la raíz (`/`). Aprenderás que `/home` equivale a `C:\Users`.
*   **Gestión de Software:** No más descargar `.exe` de sitios web desconocidos. Aquí usamos repositorios centralizados y firmados digitalmente, lo que aumenta drásticamente la seguridad.
*   **Privilegios (sudo):** Equivale a "Ejecutar como Administrador", pero con un control mucho más granular sobre lo que cada comando puede hacer.

## 4. Bibliografía y Recursos Educativos

### Sistemas Operativos y Despliegue
1.  **The Debian Administrator's Handbook:** [La biblia sobre gestión de paquetes](https://debian-handbook.info/).
2.  **Debian Wiki - debootstrap:** [Cómo construir sistemas desde cero](https://wiki.debian.org/Debootstrap).
3.  **Linux Filesystem Hierarchy Standard (FHS):** [Estructura de directorios estándar](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).

### Transición Windows -> Linux
4.  **Linux Journey:** [Curso interactivo para principiantes](https://linuxjourney.com/).
5.  **AlternativeTo Linux:** [Busca alternativas a tus programas de Windows](https://alternativeto.net/platform/linux/).
6.  **The Linux Command Line (William Shotts):** [Libro gratuito fundamental](https://linuxcommand.org/tlcl.php).

### Automatización y Programación
7.  **Google Shell Style Guide:** [Buenas prácticas en Bash](https://google.github.io/styleguide/shellguide.html).
8.  **Bash Pitfalls:** [Errores comunes que todo programador debe evitar](https://mywiki.wooledge.org/BashPitfalls).
9.  **ShellCheck:** [Linter para scripts de Bash](https://www.shellcheck.net/).

### Ciberseguridad
10. **Apt-Key Deprecation:** [Seguridad en repositorios modernos](https://wiki.debian.org/DebianRepository/UseThirdParty).
11. **NIST SP 800-115:** [Guía técnica para pruebas de seguridad](https://csrc.nist.gov/publications/detail/sp/800-115/final).
12. **MITRE ATT&CK:** [Base de conocimiento de tácticas adversarias](https://attack.mitre.org/).

### Microinformática y Hardware Virtual
13. **VBoxManage Reference:** [Control total de VirtualBox desde CLI](https://www.virtualbox.org/manual/ch08.html).
14. **CompTIA A+ Content:** [Conceptos de hardware virtual y físico](https://www.comptia.org/certifications/a).
15. **Proxmox Virtualization:** [Administración de centros de datos](https://pve.proxmox.com/pve-docs/).
