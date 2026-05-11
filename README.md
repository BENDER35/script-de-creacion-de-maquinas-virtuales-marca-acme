# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.2.8-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Ciberseguridad-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico diseñado para estudiantes y profesionales de:

*   **Sistemas y Microinformática:** Aprende cómo se construye un sistema operativo desde sus cimientos mediante `debootstrap` y cómo configurar el almacenamiento (Controlador SATA) y periféricos (Unidad Óptica).
*   **Programación:** Automatiza la creación de entornos de desarrollo limpios (sandboxes) para probar scripts o aplicaciones en diferentes distribuciones.
*   **Ciberseguridad:** Genera rápidamente laboratorios de prácticas para análisis forense, pentesting o análisis de servicios con aislamiento garantizado.
*   **Nuevos Usuarios de Linux:** Si vienes de Windows, este script te permite experimentar con Linux de forma segura y estructurada.

## 🚀 Características Principales
*   **Automatización Total:** De la ISO (vía mirror) al disco virtual (VDI/VMDK/QCOW2) sin intervención manual.
*   **Almacenamiento Avanzado (v1.2.8):** Configuración automática de controlador SATA con una **unidad óptica virtual vacía** incluida, ideal para prácticas de microinformática.
*   **Arranque Garantizado:** Lógica de instalación de GRUB optimizada para evitar fallos de arranque en discos virtuales.
*   **Conectividad Plug&Play:** Configuración automática de red (Netplan/Ifupdown) y drivers VirtIO.
*   **Ecosistema Moderno:** Soporte nativo para Flatpak, Snap y repositorios Extrepo.

## 🪟 ¿Vienes de Windows?
Si estás acostumbrado a Windows, aquí tienes unas claves para orientarte:
1.  **Sin letras de unidad:** No busques el `C:`, todo empieza en la raíz `/`.
2.  **El poder de la Terminal:** La terminal de Linux es mucho más potente que el CMD. Este script es un ejemplo de cómo automatizar tareas complejas.
3.  **Software Seguro:** En Linux, el software se instala desde "repositorios" oficiales, como una tienda de apps pero gratuita y segura.
4.  **Personalización:** Puedes elegir entre muchos "escritorios" (GNOME, KDE, XFCE). ¡Pruébalos todos con este script!

## 🛠️ Guía de Inicio para Estudiantes
Construye tu primer laboratorio virtual ejecutando:
```bash
sudo ./create_vm.sh
```
*Nota: Se requieren privilegios de superusuario para gestionar dispositivos de bloque y entornos chroot.*

## 📚 Bibliografía y Recursos de Aprendizaje

### Administración de Sistemas y Linux
1.  **Debian Handbook:** La guía definitiva del administrador Linux. [Acceso gratuito](https://www.debian.org/doc/manuals/debian-handbook/index.es.html).
2.  **Linux Journey:** Aprende Linux paso a paso de forma interactiva. [linuxjourney.com](https://linuxjourney.com/).
3.  **The Linux Command Line:** El libro esencial para dominar la terminal. [linuxcommand.org](https://linuxcommand.org/tlcl.php).

### Automatización, Programación y Seguridad
4.  **ShellCheck:** Analiza y mejora tus scripts de Bash. [shellcheck.net](https://www.shellcheck.net/).
5.  **OWASP DevSecOps:** Seguridad en el ciclo de desarrollo y automatización.
6.  **Google Shell Style Guide:** Estándares profesionales de programación en Shell.

---
*Desarrollado como herramienta de apoyo para la formación profesional en informática y comunicaciones.*
