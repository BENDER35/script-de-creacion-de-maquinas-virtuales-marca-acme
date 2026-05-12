# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.3.1-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Ciberseguridad-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico diseñado para estudiantes y profesionales de:

*   **Sistemas y Microinformática:** Aprende cómo se construye un sistema operativo desde sus cimientos mediante `debootstrap` y cómo configurar el almacenamiento (Controlador SATA) y periféricos (Unidad Óptica).
*   **Programación:** Automatiza la creación de entornos de desarrollo limpios (sandboxes) para probar scripts o aplicaciones en diferentes distribuciones. Aprende lógica de scripting profesional.
*   **Ciberseguridad:** Genera rápidamente laboratorios de prácticas para análisis forense, pentesting o análisis de servicios con aislamiento garantizado mediante sandboxing (Flatpak).
*   **Artistas, Ilustradores y Creadores Digitales:** Si te dedicas al diseño, la ilustración o el streaming, este script te permite desplegar **Ubuntu Studio**, un entorno profesional pre-configurado, o **Unity** para una experiencia clásica. El ecosistema Linux es el estándar en la industria del cine y VFX.
*   **Nuevos Usuarios de Linux:** Si vienes de Windows, este script te permite experimentar con Linux de forma segura, estructurada y sin miedo a "romper" tu sistema principal.

## 🚀 Características Principales
*   **Automatización Total:** De la ISO (vía mirror) al disco virtual (VDI/VMDK/QCOW2) sin intervención manual.
*   **Modo No Interactivo (v1.3.0):** Soporte completo para parámetros por línea de comandos, facilitando la integración en scripts de mayor nivel.
*   **Gestión Inteligente de Flatpak (v1.3.0):** Resolución automática de IDs de aplicaciones. Instala `vlc`, `spotify` o `bottles` simplemente tecleando su nombre.
*   **Almacenamiento Avanzado:** Configuración automática de controlador SATA con una **unidad óptica virtual vacía** incluida, ideal para prácticas de microinformática.
*   **Ubuntu Studio y Unity:** Soporte para el sabor creativo de Ubuntu y la interfaz clásica Unity. Incluye advertencias pedagógicas sobre ciclos de vida de software (LTS vs No-LTS).
*   **Ecosistema Moderno:** Soporte nativo para Flatpak, Snap y repositorios Extrepo.

## 🪟 ¿Vienes de Windows? Tu primer paso en Linux
Si estás acostumbrado a Windows, la transición puede parecer un reto, pero Linux ofrece una libertad sin igual:
1.  **Sin letras de unidad:** No busques el `C:`, todo empieza en la raíz `/`. Es una estructura jerárquica más lógica una vez que la conoces.
2.  **El poder de la Terminal:** La terminal de Linux es una herramienta de precisión, no un "último recurso". Este script es un ejemplo de cómo automatizar en segundos lo que en Windows llevaría horas de clics.
3.  **Software Seguro y Centralizado:** En Linux, el software se instala desde "repositorios" oficiales o formatos modernos como Flatpak, eliminando el riesgo de descargar instaladores `.exe` maliciosos.
4.  **Aislamiento (Sandboxing):** Con Flatpak, las aplicaciones corren en una "caja de arena", protegiendo tu sistema operativo de posibles fallos o vulnerabilidades de la app.
5.  **Entorno Creativo Profesional:** Si vienes de usar Windows para diseño o streaming, **Ubuntu Studio** te ofrece un kernel de baja latencia (optimizado para audio) y software como Krita, Blender y OBS pre-instalados o listos para usar con un rendimiento profesional.

## 🛠️ Guía de Inicio Rápido
Construye tu primer laboratorio virtual con un solo comando:
```bash
# Ejemplo para crear una VM Ubuntu con GNOME y VLC
sudo ./create_vm.sh --name laboratorio_progra --os ubuntu --desktop gnome --flatpak vlc
```
*Nota: Se requieren privilegios de superusuario para gestionar dispositivos de bloque y entornos chroot.*

## 📚 Bibliografía y Recursos de Aprendizaje

### 🛠️ Sistemas y Administración (SMR/ASIR)
1.  **Debian Handbook:** La guía definitiva del administrador Linux. [Acceso gratuito](https://www.debian.org/doc/manuals/debian-handbook/index.es.html).
2.  **Arch Wiki:** Aunque uses Debian/Ubuntu, es el mejor recurso sobre conceptos generales de Linux. [wiki.archlinux.org](https://wiki.archlinux.org/).
3.  **Linux Journey:** Aprende Linux paso a paso de forma interactiva. [linuxjourney.com](https://linuxjourney.com/).
4.  **FHS Standard:** Entendiendo la jerarquía del sistema de archivos.

### 💻 Programación y Desarrollo
5.  **The Linux Command Line:** El libro esencial para dominar la terminal. [linuxcommand.org](https://linuxcommand.org/tlcl.php).
6.  **Google Shell Style Guide:** Estándares profesionales de programación en Shell.
7.  **Full Stack Open:** Curso excelente que cubre despliegue en entornos Linux/Docker. [fullstackopen.com](https://fullstackopen.com/es/).
8.  **Bash Guide for Beginners:** [Machtelt Garrels](https://tldp.org/LDP/Bash-Beginners-Guide/html/).

### 🛡️ Ciberseguridad
9.  **OverTheWire (Bandit):** Aprende seguridad y terminal mediante juegos de retos. [overthewire.org](https://overthewire.org/wargames/bandit/).
10. **Hack The Box Academy:** Fundamentos de Linux para ciberseguridad.
11. **OWASP DevSecOps:** Seguridad en el ciclo de desarrollo y automatización.
12. **NIST Cybersecurity Framework:** Referencia para la protección de infraestructuras.

### 🔌 Microinformática y Hardware Virtual
13. **VBoxManage Reference:** Control total de VirtualBox desde CLI. [virtualbox.org](https://www.virtualbox.org/manual/ch08.html).
14. **Proxmox Documentation:** Aprende sobre virtualización de nivel empresarial.
15. **CompTIA A+ Study Guide:** Conceptos de hardware aplicables a entornos virtuales.
16. **QEMU/KVM Virtualization:** [Kernel-based Virtual Machine](https://www.linux-kvm.org/).

### 🎨 Diseño, Ilustración y Streaming
17. **Krita Digital Painting:** Manual profesional de ilustración. [krita.org](https://docs.krita.org/).
18. **Blender 3D:** El estándar de código abierto para 3D y VFX. [blender.org](https://docs.blender.org/).
19. **OBS Studio Wiki:** Configuración avanzada para streamers en Linux.
20. **Inkscape Tutorials:** Diseño vectorial profesional.
21. **GIMP Manual:** Edición avanzada de imágenes.
22. **Linux Music Workflow:** Producción de audio y MIDI.

### 🐧 Interesados en Linux (Transición desde Windows)
23. **Linux Journey (Español):** Guía visual para principiantes.
24. **Ubuntu Community Help:** Soluciones a problemas comunes al migrar.
25. **AlternativeTo:** Encuentra el equivalente en Linux de tus apps de Windows. [alternativeto.net](https://alternativeto.net/).
26. **ProtonDB:** Compatibilidad de juegos en Linux.
27. **DistroSea:** Prueba Linux en tu navegador.

---
*Desarrollado como herramienta de apoyo para la formación profesional en informática y comunicaciones.*


---
*Desarrollado como herramienta de apoyo para la formación profesional en informática y comunicaciones.*
