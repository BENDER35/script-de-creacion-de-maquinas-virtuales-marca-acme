# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad**, **Programación** y **Microinformática** que deseen entender cómo orquestar la creación de entornos Linux de forma profesional y resiliente.

## 1. Arquitectura y Robustez (v1.3.1)

El script `create_vm.sh` ha evolucionado para incluir mecanismos de "autocuración" y preparación de entornos avanzados:

*   **Interfaz de Línea de Comandos (CLI):** Se ha implementado un sistema de parseo de argumentos que permite el uso de flags como `--name`, `--os`, `--desktop` y `--flatpak`. Esto permite la integración del script en flujos de CI/CD o scripts de automatización superiores, una competencia esencial en **DevOps**.
*   **Gestión Inteligente de Almacenamiento:** Se ha estandarizado el uso de controladores SATA para VirtualBox. Además del disco duro principal (`.vdi`), el script adjunta automáticamente una **unidad óptica virtual vacía**. Esto permite a los estudiantes de microinformática practicar el montaje de imágenes ISO (como GParted o discos de rescate) de forma dinámica.
*   **Configuración de Red e Interoperabilidad:** Configuración DHCP mediante Netplan (Ubuntu) e `ifupdown` (Debian). El uso de drivers **VirtIO** asegura un rendimiento óptimo en laboratorios de redes y ciberseguridad.
*   **Ubuntu Studio y Unity:** Soporte integrado para laboratorios creativos y nostálgicos. Unity se ofrece con una advertencia específica sobre su ciclo de vida no-LTS, ideal para el estudio de distribuciones comunitarias. Ubuntu Studio optimiza el sistema con un kernel de baja latencia, vital para el audio profesional y el streaming.

## 2. Gestión de Paquetes y Sandboxing

El script integra tecnologías de vanguardia para la distribución y aislamiento de software:

### Flatpak: Resolución de IDs y Aislamiento (v1.3.0)
*   **Lógica de Búsqueda:** El script utiliza `flatpak search --columns=application` para resolver nombres comunes (ej: `vlc`) a Application IDs unívocos (ej: `org.videolan.VLC`). Esto simplifica drásticamente la experiencia del usuario final.
*   **Relevancia en Ciberseguridad:** El uso de `bubblewrap` para el sandboxing es un concepto fundamental en la seguridad de aplicaciones moderna. Estudiar cómo se instala Flatpak en un entorno `chroot` ayuda a comprender los niveles de aislamiento del kernel Linux.

### Snap: Contenedores de Aplicación
*   **Relevancia en Programación:** Permite gestionar herramientas de desarrollo con dependencias aisladas. El script prepara el entorno para que el demonio `snapd` pueda operar correctamente tras el primer arranque.

### Extrepo: Gestión de Repositorios Seguros
*   **Relevancia en Sistemas:** Demuestra cómo gestionar repositorios de terceros de forma segura, utilizando llaves GPG y evitando la contaminación de `sources.list` mediante archivos específicos en `sources.list.d`.

## 3. Guía Pedagógica para Estudiantes

### Para Futuros Programadores
*   **Análisis del Script:** Observa cómo se utilizan los *Heredocs* (`cat <<CHROOT_SCRIPT`) para inyectar lógica de un entorno (Host) a otro (Guest/Chroot). Es una técnica avanzada de automatización.
*   **Lógica de Flags:** Estudia el bucle `while [[ "$#" -gt 0 ]]` para entender cómo se procesan parámetros en Bash.

### Para Artistas, Diseñadores e Ilustradores (Migración desde Windows)
*   **Software Libre vs Propietario:** Entiende cómo herramientas como Krita, GIMP, Inkscape y Blender sustituyen y, en muchos casos, superan los flujos de trabajo tradicionales en Windows.
*   **Rendimiento de Audio:** Aprende por qué el kernel de baja latencia de Ubuntu Studio es superior para la grabación y el streaming comparado con el modelo de drivers de audio estándar de Windows.
*   **Producción Profesional:** Linux es el estándar en grandes estudios de efectos visuales (VFX) y animación.

### Para Especialistas en Ciberseguridad
*   **Análisis de Superficie de Ataque:** Al crear máquinas virtuales limpias con solo el software necesario, estás reduciendo la superficie de ataque, un principio básico de *hardening*.
*   **Sandboxing:** Entiende por qué es mejor instalar una aplicación vía Flatpak que mediante un `.deb` tradicional cuando no confías plenamente en el origen del software.

### Para Administradores de Sistemas (Linux Newcomers)
*   **Jerarquía de Archivos:** Aprende que en Linux no hay "Letras de Unidad". Todo es un archivo o un directorio colgando de `/`.
*   **Permisos y Propietarios:** El script utiliza `chown` y `chmod` para asegurar que el nuevo usuario tenga los permisos correctos en su `/home`.

## 4. Bibliografía y Recursos Educativos

### Sistemas Operativos y Despliegue (SMR/ASIR)
1.  **The Debian Administrator's Handbook:** [La biblia sobre gestión de paquetes](https://debian-handbook.info/).
2.  **Debian Wiki - debootstrap:** [Cómo construir sistemas desde cero](https://wiki.debian.org/Debootstrap).
3.  **Linux Filesystem Hierarchy Standard (FHS):** [Estructura de directorios estándar](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).
4.  **TLDP - Linux Filesystem Hierarchy:** [Guía detallada sobre el sistema de archivos](https://tldp.org/LDP/Linux-Filesystem-Hierarchy/html/).

### Automatización y Programación
5.  **Google Shell Style Guide:** [Buenas prácticas en Bash](https://google.github.io/styleguide/shellguide.html).
6.  **Bash Pitfalls:** [Errores comunes que todo programador debe evitar](https://mywiki.wooledge.org/BashPitfalls).
7.  **Advanced Bash-Scripting Guide:** [Referencia completa de scripting](https://tldp.org/LDP/abs/html/).
8.  **Full Stack Open - Docker:** [Introducción a la contenedorización](https://fullstackopen.com/es/part12).

### Ciberseguridad y Aislamiento
9.  **Flatpak Documentation:** [Entendiendo el sandboxing y el aislamiento](https://docs.flatpak.org/).
10. **NIST SP 800-115:** [Guía técnica para pruebas de seguridad](https://csrc.nist.gov/publications/detail/sp/800-115/final).
11. **OWASP DevSecOps Guideline:** [Seguridad en la automatización](https://owasp.org/www-project-devsecops-guideline/).
12. **TryHackMe - Linux Fundamentals:** [Laboratorios interactivos de seguridad en Linux](https://tryhackme.com/module/linux-fundamentals).

### Microinformática y Hardware Virtual
13. **VBoxManage Reference:** [Control total de VirtualBox desde CLI](https://www.virtualbox.org/manual/ch08.html).
14. **CompTIA A+ Content:** [Conceptos de hardware virtual y físico](https://www.comptia.org/certifications/a).
15. **Proxmox Virtualization Documentation:** [Administración de centros de datos](https://pve.proxmox.com/pve-docs/).
16. **QEMU Documentation:** [Manual oficial del emulador y virtualizador](https://www.qemu.org/documentation/).

### Creación Digital, Diseño y Streaming
17. **Ubuntu Studio Manual:** [Configuración para producción multimedia](https://ubuntustudio.org/tour/).
18. **Krita Foundation:** [Manual oficial del software de pintura digital](https://docs.krita.org/).
19. **Blender Manual:** [Documentación completa para 3D y VFX](https://docs.blender.org/).
20. **OBS Studio Wiki:** [Guía de configuración para streaming en Linux](https://obsproject.com/wiki/).
21. **Inkscape Tutorials:** [Aprendizaje de diseño vectorial](https://inkscape.org/learn/tutorials/).
22. **Linux Music Workflow:** [Recursos para producción de audio en Linux](https://linuxmusicians.com/).

### Transición Windows -> Linux (Migración)
23. **Linux Journey:** [Curso interactivo y visual para principiantes](https://linuxjourney.com/).
24. **Ubuntu Community Help:** [Guías de migración y uso básico](https://help.ubuntu.com/).
25. **AlternativeTo:** [Encuentra el equivalente en Linux de tus apps de Windows](https://alternativeto.net/).
26. **ProtonDB:** [Comprueba la compatibilidad de tus juegos de Windows en Linux](https://www.protondb.com/).
27. **DistroSea:** [Prueba distribuciones Linux directamente en tu navegador](https://distrosea.com/).
