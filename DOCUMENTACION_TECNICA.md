# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad**, **Programación** y **Microinformática**, así como para **migrantes de Windows** y **profesionales creativos** que buscan una alternativa potente y económica.

## 1. Arquitectura y Robustez (v1.3.2)

El script `create_vm.sh` ha evolucionado para incluir mecanismos de "autocuración" y preparación de entornos avanzados:

*   **Interfaz de Línea de Comandos (CLI):** Se ha implementado un sistema de parseo de argumentos que permite el uso de flags como `--name`, `--os`, `--desktop` y `--flatpak`. Esto permite la integración del script en flujos de CI/CD o scripts de automatización superiores, una competencia esencial en **DevOps**.
*   **Gestión Inteligente de Almacenamiento:** Se ha estandarizado el uso de controladores SATA para VirtualBox. Además del disco duro principal (`.vdi`), el script adjunta automáticamente una **unidad óptica virtual vacía**. Esto permite a los estudiantes de microinformática practicar el montaje de imágenes ISO (como GParted o discos de rescate) de forma dinámica.
*   **Gestión Dinámica de Red (NetworkManager):** A partir de la v1.3.2, el script detecta si se ha seleccionado un escritorio gráfico. De ser así, configura Netplan para usar `NetworkManager` como renderizador, asegurando que el icono de red y la gestión desde la UI de GNOME/KDE/XFCE funcionen correctamente. En modo servidor (sin escritorio), mantiene `networkd` para mayor ligereza.
*   **Ubuntu Studio y Unity:** Soporte integrado para laboratorios creativos y nostálgicos. Unity se ofrece con una advertencia específica sobre su ciclo de vida no-LTS, ideal para el estudio de distribuciones comunitarias. Ubuntu Studio optimiza el sistema con un kernel de baja latencia, vital para el audio profesional y el streaming.

## 2. Gestión de Paquetes y Sandboxing
... (mantener igual) ...

## 3. Guía de Orientación por Perfiles

### A. Estudiantes de IT (Sistemas, Redes, Ciberseguridad)
*   **Microinformática:** El script automatiza la creación de discos `.vdi` y `.vmdk`, permitiendo entender la diferencia entre formatos de virtualización.
*   **Ciberseguridad:** Crear máquinas "limpias" mediante debootstrap minimiza la superficie de ataque. Aprender a usar `flatpak` y `bubblewrap` es vital para el aislamiento de procesos.
*   **Programación:** El uso de *Heredocs* y la gestión de variables en Bash es un caso de estudio real sobre automatización de despliegues.

### B. Migrantes desde Windows (Guía de Supervivencia)
*   **¿Dónde están mis discos (C:, D:)?** En Linux todo cuelga de la raíz `/`. Tus archivos están en `/home/usuario`.
*   **Instalación de programas:** Olvida buscar `.exe` en webs dudosas. Usa el Centro de Software, `apt` o `flatpak`. Es más seguro y rápido.
*   **El terminal no muerde:** Aunque puedes hacer casi todo con el ratón, el terminal es tu mejor amigo para tareas repetitivas. El script `create_vm.sh` es un ejemplo de ello.

### C. Creativos: Diseño, Vídeo y Streaming (El factor económico)
*   **Hardware antiguo = Rendimiento nuevo:** Si tu PC no puede con Windows 11 o las últimas versiones de Adobe, Linux le dará una segunda vida. Distros como XFCE o MATE consumen una fracción de la RAM que usa Windows.
*   **Alternativas Profesionales:**
    *   **Adobe Photoshop -> Krita / GIMP:** Krita es el estándar para ilustración digital. GIMP para edición fotográfica.
    *   **Adobe Premiere -> DaVinci Resolve / Kdenlive:** Kdenlive es excelente para edición ágil; DaVinci es el estándar de Hollywood disponible en Linux.
    *   **Streaming -> OBS Studio:** Funciona de forma nativa y más eficiente en Linux.
    *   **Audio:** El kernel de baja latencia permite grabar audio sin el retardo (latencia) que suele ocurrir en Windows sin drivers ASIO caros.

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
