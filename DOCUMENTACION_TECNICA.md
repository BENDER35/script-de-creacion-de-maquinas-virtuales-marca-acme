# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad**, **Programación** y **Microinformática** que deseen entender cómo orquestar la creación de entornos Linux de forma profesional y resiliente.

## 1. Arquitectura y Robustez (v1.2.7)

El script `create_vm.sh` ha evolucionado para incluir mecanismos de "autocuración" y preparación de entornos minimalistas:

*   **Instalación Silenciosa de Bootloaders:** Se ha corregido la inyección de variables en el entorno `chroot` para asegurar que el cargador de arranque GRUB se instale en el MBR del disco virtual. El uso de escapes en los *Heredocs* (`\$1`) es una técnica fundamental en scripting avanzado para diferenciar entre variables del host y variables del invitado.
*   **Configuración de Red Nativa (DHCP):** Se ha implementado una solución de conectividad robusta. Para **Ubuntu**, se genera dinámicamente un archivo Netplan que utiliza un selector de nombres (`e*`) para capturar cualquier interfaz Ethernet (enp0s3, eth0). Para **Debian**, se utiliza el sistema tradicional `ifupdown` configurando las interfaces más comunes.
*   **Aceleración por VirtIO:** En la capa de VirtualBox, el script configura el adaptador de red como `virtio`. Esto permite que el kernel del invitado se comunique con el hipervisor de forma más directa, reduciendo la latencia y mejorando la tasa de transferencia.
*   **Inyección de Variables y Generación Dinámica:** Se utiliza la técnica de *Heredocs* para generar `setup.sh`. Las listas de paquetes se inyectan desde el host, permitiendo una personalización del software.
*   **Preparación del Entorno Mínimo:** Dado que `debootstrap` crea un sistema extremadamente base, el script ahora pre-crea estructuras de directorios críticas (ej. `/etc/initramfs-tools/conf.d`). Esto evita que los scripts de post-instalación de paquetes como Plymouth fallen al no encontrar rutas esperadas.
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
4.  **Arch Wiki - Chroot:** [Conceptos y seguridad en entornos chroot](https://wiki.archlinux.org/title/Chroot).

### Automatización y Programación
5.  **Google Shell Style Guide:** [Estándares profesionales en Bash](https://google.github.io/styleguide/shellguide.html).
6.  **Pure Bash Bible:** [Técnicas avanzadas sin dependencias externas](https://github.com/dylanaraps/pure-bash-bible).
7.  **Bash Pitfalls:** [Errores comunes y cómo evitarlos (Indispensable)](https://mywiki.wooledge.org/BashPitfalls).
8.  **ShellyCheck:** [Herramienta de análisis estático para scripts de Bash](https://www.shellcheck.net/).

### Ciberseguridad
9.  **Apt-Key Deprecation:** [Por qué no usar apt-key y usar signed-by](https://wiki.debian.org/DebianRepository/UseThirdParty).
10. **NIST SP 800-92:** [Guía para la gestión de logs y auditoría](https://csrc.nist.gov/publications/detail/sp/800-92/final).
11. **MITRE ATT&CK - Persistence:** [Entender cómo se usan los scripts de inicio para persistencia](https://attack.mitre.org/tactics/TA0003/).

### Redes y Conectividad
12. **Netplan Design:** [Arquitectura de configuración de red en Ubuntu](https://netplan.io/design/).
13. **VirtIO Networking:** [Beneficios de la paravirtualización de red](https://wiki.libvirt.org/page/Virtio).

### Virtualización y Microinformática
14. **VBoxManage Reference:** [Automatización de VirtualBox desde CLI](https://www.virtualbox.org/manual/ch08.html).
15. **CompTIA A+ Study Guide:** [Fundamentos de hardware y sistemas operativos](https://www.comptia.org/certifications/a).
16. **Proxmox Documentation:** [Administración de contenedores y VMs a gran escala](https://pve.proxmox.com/pve-docs/).
