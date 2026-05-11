# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.2.7-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Ciberseguridad-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico diseñado para estudiantes y profesionales de:

*   **Sistemas y Microinformática:** Aprende cómo se construye un sistema operativo desde sus cimientos mediante `debootstrap` y cómo configurar el arranque (GRUB) y la red de forma nativa.
*   **Programación:** Automatiza la creación de entornos de desarrollo limpios (sandboxes) para probar scripts o aplicaciones en diferentes distribuciones sin ensuciar tu máquina host.
*   **Ciberseguridad:** Genera rápidamente laboratorios de prácticas para análisis forense, pruebas de penetración o análisis de servicios, con aislamiento garantizado.

## 🚀 Características Principales
*   **Automatización Total:** De la ISO (vía mirror) al disco virtual (VDI/VMDK/QCOW2) sin intervención manual.
*   **Arranque Garantizado (v1.2.7):** Corrección de lógica en la instalación de GRUB para asegurar la viabilidad del disco en cualquier hipervisor.
*   **Conectividad Plug&Play:** Configuración automática de red (Netplan/Ifupdown) y drivers VirtIO de alto rendimiento.
*   **Ecosistema Moderno:** Soporte nativo para Flatpak, Snap y repositorios Extrepo.
*   **Personalización Visual:** Inyección automática de fondos de pantalla (locales o desde Wallhaven) para identificar tus laboratorios.

## 🛠️ Guía de Inicio para Estudiantes
Para iniciar la construcción de tu primer laboratorio virtual, clona el repositorio y ejecuta:
```bash
sudo ./create_vm.sh
```
*Nota: Se requieren privilegios de superusuario para gestionar dispositivos de bloque y entornos chroot.*

## 📚 Bibliografía y Recursos de Aprendizaje
Para profundizar en las tecnologías que utiliza este script, consulta nuestra **Documentación Técnica** detallada o estos recursos externos:

### Administración de Sistemas
1.  **Debian Handbook:** La biblia del administrador de sistemas Linux. [Acceso gratuito](https://www.debian.org/doc/manuals/debian-handbook/index.es.html).
2.  **Linux Journey:** Un camino interactivo para aprender terminal y sistemas. [linuxjourney.com](https://linuxjourney.com/).

### Automatización y Seguridad
3.  **ShellCheck:** Aprende a escribir mejores scripts analizando tu código. [shellcheck.net](https://www.shellcheck.net/).
4.  **OWASP DevSecOps:** Guías sobre cómo integrar seguridad en la automatización.

---
*Desarrollado como herramienta de apoyo para la formación profesional en informática y comunicaciones.*
