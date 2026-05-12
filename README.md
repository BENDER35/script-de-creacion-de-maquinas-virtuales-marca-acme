# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.3.0-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Ciberseguridad-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico diseñado para estudiantes y profesionales de:

*   **Sistemas y Microinformática:** Aprende cómo se construye un sistema operativo desde sus cimientos mediante `debootstrap` y cómo configurar el almacenamiento (Controlador SATA) y periféricos (Unidad Óptica).
*   **Programación:** Automatiza la creación de entornos de desarrollo limpios (sandboxes) para probar scripts o aplicaciones en diferentes distribuciones. Aprende lógica de scripting profesional.
*   **Ciberseguridad:** Genera rápidamente laboratorios de prácticas para análisis forense, pentesting o análisis de servicios con aislamiento garantizado mediante sandboxing (Flatpak).
*   **Artistas y Creadores Digitales:** Si eres ilustrador, diseñador o streamer, este script te permite desplegar **Ubuntu Studio**, un entorno profesional pre-configurado con herramientas de baja latencia y software creativo de vanguardia.
*   **Nuevos Usuarios de Linux:** Si vienes de Windows, este script te permite experimentar con Linux de forma segura, estructurada y sin miedo a "romper" tu sistema principal.

## 🚀 Características Principales
*   **Automatización Total:** De la ISO (vía mirror) al disco virtual (VDI/VMDK/QCOW2) sin intervención manual.
*   **Modo No Interactivo (v1.3.0):** Soporte completo para parámetros por línea de comandos, facilitando la integración en scripts de mayor nivel.
*   **Gestión Inteligente de Flatpak (v1.3.0):** Resolución automática de IDs de aplicaciones. Instala `vlc`, `spotify` o `bottles` simplemente tecleando su nombre.
*   **Almacenamiento Avanzado:** Configuración automática de controlador SATA con una **unidad óptica virtual vacía** incluida, ideal para prácticas de microinformática.
*   **Ubuntu Studio:** Soporte para el sabor creativo de Ubuntu, facilitando laboratorios de diseño y producción multimedia. Ideal para probar la transición desde herramientas como Adobe o OBS en Windows.
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

### 🛠️ Sistemas y Administración
1.  **Debian Handbook:** La guía definitiva del administrador Linux. [Acceso gratuito](https://www.debian.org/doc/manuals/debian-handbook/index.es.html).
2.  **Arch Wiki:** Aunque uses Debian/Ubuntu, es el mejor recurso sobre conceptos generales de Linux. [wiki.archlinux.org](https://wiki.archlinux.org/).
3.  **Linux Journey:** Aprende Linux paso a paso de forma interactiva. [linuxjourney.com](https://linuxjourney.com/).

### 💻 Programación y Desarrollo
4.  **The Linux Command Line:** El libro esencial para dominar la terminal. [linuxcommand.org](https://linuxcommand.org/tlcl.php).
5.  **Google Shell Style Guide:** Estándares profesionales de programación en Shell.
6.  **Full Stack Open:** Curso excelente que cubre despliegue en entornos Linux/Docker. [fullstackopen.com](https://fullstackopen.com/es/).

### 🛡️ Ciberseguridad
7.  **OverTheWire (Bandit):** Aprende seguridad y terminal mediante juegos de retos. [overthewire.org](https://overthewire.org/wargames/bandit/).
8.  **Hack The Box Academy:** Fundamentos de Linux para ciberseguridad.
9.  **OWASP DevSecOps:** Seguridad en el ciclo de desarrollo y automatización.

### 🔌 Microinformática y Hardware Virtual
10. **VBoxManage Reference:** Control total de VirtualBox desde CLI. [virtualbox.org](https://www.virtualbox.org/manual/ch08.html).
11. **Proxmox Documentation:** Aprende sobre virtualización de nivel empresarial.
12. **CompTIA A+ Study Guide:** Conceptos de hardware aplicables a entornos virtuales.

### 🐧 Interesados en Linux (Transición desde Windows)
13. **Linux Journey (Español):** Guía visual para principiantes.
14. **Ubuntu Community Help:** Soluciones a problemas comunes al migrar.
15. **AlternativeTo:** Encuentra el equivalente en Linux de tus apps de Windows. [alternativeto.net](https://alternativeto.net/).

---
*Desarrollado como herramienta de apoyo para la formación profesional en informática y comunicaciones.*
