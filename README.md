# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.4.0-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Creativos-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico y profesional diseñado para:

*   **Sistemas, Ciberseguridad y Microinformática:** Aprende la arquitectura de Linux desde sus cimientos (`debootstrap`). Genera laboratorios aislados y seguros para prácticas de redes o forense.
*   **Programación y DevOps:** Automatiza entornos de desarrollo reproducibles. El script es un caso de estudio real de scripting avanzado en Bash y despliegue automatizado.
*   **Migrantes de Windows (Hogar y Oficina):** Experimenta con Linux de forma segura. Descubre una estructura jerárquica lógica y un sistema libre de virus y telemetría intrusiva.
*   **Creativos (Diseño, Edición, Ilustración, Streaming):** 
    *   **Salvavidas Económico:** Si tu equipo no soporta Windows 11 o las últimas versiones de Adobe, Linux (vía Ubuntu Studio) te ofrece un rendimiento profesional en hardware "antiguo".
    *   **Estándar de la Industria:** Linux es el motor de los grandes estudios de efectos visuales (VFX) y animación.

## 🚀 Características Principales
*   **Arranque Robusto (v1.4.0):** Corrección del error `normal.mod not found` mediante la reordenación de la instalación de GRUB y la inclusión de módulos críticos (`ext2`, `biosdisk`). ¡Sistemas gráficos que arrancan siempre a la primera!
*   **Gestión Dinámica de Red:** Detección automática de entorno gráfico para habilitar `NetworkManager`.
*   **Automatización Total:** De la descarga (vía mirror inteligente) al disco virtual listo para arrancar.
*   **Soporte Multimedia Avanzado:** Despliega **Ubuntu Studio** para audio de baja latencia o **Unity** para una experiencia clásica.
*   **Software Moderno:** Integración de Flatpak (con búsqueda inteligente), Snap y Extrepo.

## 🪟 Guía de Supervivencia para Usuarios de Windows
Si vienes de Windows por necesidad o curiosidad, aquí tienes tus puntos de orientación:
1.  **Tu casa es `/home/usuario`:** Olvida el `C:`. Tus archivos están en tu carpeta personal dentro de `/home`.
2.  **El Centro de Software es tu "Tienda":** No busques instaladores por internet. Todo el software profesional (Krita, OBS, Blender, Kdenlive) está a un clic en los repositorios oficiales.
3.  **Rendimiento Real:** Donde Windows se "atasca" con actualizaciones pesadas, Linux vuela. Es ideal para dar una segunda vida a portátiles de hace 5-8 años.
4.  **Libertad y Privacidad:** Tú tienes el control total del sistema. Sin actualizaciones forzadas ni publicidad en el menú de inicio.

## 🎨 Solución para Creativos sin Presupuesto
¿Tu PC no puede con las suscripciones de Adobe o los requisitos de Windows 11?
- **Ilustración:** Cambia Photoshop por **Krita**. Es gratuito, de código abierto y usado por profesionales de la industria del anime y el cómic.
- **Vídeo:** **Kdenlive** y **DaVinci Resolve** (versión Linux) ofrecen herramientas de montaje de nivel cinematográfico sin coste de licencia.
- **3D:** **Blender** corre mejor en Linux, aprovechando mejor la RAM y la CPU para renderizados.
- **Streaming:** **OBS Studio** en Linux consume menos recursos, permitiendo emitir con mayor calidad en hardware modesto.

## 🛠️ Guía de Inicio Rápido
Crea tu entorno creativo o técnico con un solo comando:
```bash
# Ejemplo: Ubuntu con escritorio XFCE (muy ligero) y software de edición
sudo ./create_vm.sh --name estudio_creativo --os ubuntu --desktop xfce --flatpak kdenlive,krita,obs-studio
```
*Nota: Se requieren privilegios de superusuario (sudo) para la construcción de la imagen.*

## 📚 Bibliografía y Recursos de Aprendizaje

### 🛠️ Sistemas y Administración (SMR/ASIR)
1.  **Debian Handbook:** La guía definitiva del administrador Linux. [Acceso gratuito](https://www.debian.org/doc/manuals/debian-handbook/index.es.html).
2.  **Arch Wiki:** El mejor recurso sobre conceptos generales de Linux. [wiki.archlinux.org](https://wiki.archlinux.org/).
3.  **Linux Journey:** Aprende Linux paso a paso de forma interactiva. [linuxjourney.com](https://linuxjourney.com/).
4.  **FHS Standard:** Entendiendo la jerarquía del sistema de archivos.

### 💻 Programación y Desarrollo
5.  **The Linux Command Line:** El libro esencial para dominar la terminal. [linuxcommand.org](https://linuxcommand.org/tlcl.php).
6.  **Google Shell Style Guide:** Estándares profesionales de programación en Shell.
7.  **Full Stack Open:** Curso excelente que cubre despliegue en entornos Linux. [fullstackopen.com](https://fullstackopen.com/es/).

### 🛡️ Ciberseguridad
8.  **OverTheWire (Bandit):** Aprende seguridad y terminal mediante juegos de retos. [overthewire.org](https://overthewire.org/wargames/bandit/).
9.  **Hack The Box Academy:** Fundamentos de Linux para ciberseguridad.
10. **OWASP DevSecOps:** Seguridad en el ciclo de desarrollo y automatización.

### 🔌 Microinformática y Hardware Virtual
11. **VBoxManage Reference:** Control total de VirtualBox desde CLI. [virtualbox.org](https://www.virtualbox.org/manual/ch08.html).
12. **Proxmox Documentation:** Aprende sobre virtualización de nivel empresarial.
13. **QEMU/KVM Virtualization:** [Kernel-based Virtual Machine](https://www.linux-kvm.org/).

### 🎨 Diseño, Ilustración y Streaming
14. **Krita Digital Painting:** Manual profesional de ilustración. [krita.org](https://docs.krita.org/).
15. **Blender 3D:** El estándar de código abierto para 3D y VFX. [blender.org](https://docs.blender.org/).
16. **OBS Studio Wiki:** Configuración avanzada para streamers en Linux.
17. **Linux Music Workflow:** Producción de audio y MIDI sin latencia.

### 🐧 Interesados en Linux (Transición desde Windows)
18. **Linux Journey (Español):** Guía visual para principiantes.
19. **Ubuntu Community Help:** Soluciones a problemas comunes al migrar.
20. **AlternativeTo:** Encuentra el equivalente en Linux de tus apps de Windows. [alternativeto.net](https://alternativeto.net/).
21. **DistroSea:** Prueba Linux en tu navegador antes de instalarlo.

---
*Desarrollado como herramienta de apoyo para la formación profesional en informática y comunicaciones.*
