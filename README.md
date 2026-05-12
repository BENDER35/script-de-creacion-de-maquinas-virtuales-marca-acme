# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.3.2-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Creativos-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico y profesional diseñado para:

*   **Sistemas, Ciberseguridad y Microinformática:** Aprende la arquitectura de Linux desde sus cimientos (`debootstrap`). Genera laboratorios aislados y seguros (Sandboxing) para prácticas de redes o forense.
*   **Programación y DevOps:** Automatiza entornos de desarrollo reproducibles. El script es un caso de estudio real de scripting avanzado en Bash y despliegue automatizado.
*   **Migrantes de Windows (Hogar y Oficina):** Experimenta con Linux de forma segura. Descubre una estructura jerárquica lógica y un sistema libre de virus y telemetría intrusiva.
*   **Creativos (Diseño, Edición, Ilustración, Streaming):** 
    *   **Salvavidas Económico:** Si tu equipo no soporta Windows 11 o las últimas versiones de Adobe, Linux (vía Ubuntu Studio) te ofrece un rendimiento profesional en hardware "antiguo".
    *   **Estándar de la Industria:** Linux es el motor de los grandes estudios de efectos visuales (VFX) y animación.

## 🚀 Características Principales
*   **Gestión Dinámica de Red (v1.3.2):** Detección automática de entorno gráfico para habilitar `NetworkManager`. ¡Dile adiós a los problemas de red tras la instalación!
*   **Automatización Total:** De la descarga (vía mirror inteligente) al disco virtual listo para arrancar.
*   **Soporte Multimedia Avanzado:** Despliega **Ubuntu Studio** para audio de baja latencia o **Unity** para una experiencia clásica.
*   **Software Moderno:** Integración de Flatpak (con búsqueda inteligente), Snap y Extrepo.
*   **Almacenamiento Profesional:** Controlador SATA con unidad óptica virtual incluida para prácticas de rescate de sistemas.

## 🪟 Guía de Supervivencia para Usuarios de Windows
Si vienes de Windows por necesidad o curiosidad, aquí tienes tus puntos de orientación:
1.  **Tu casa es `/home/usuario`:** Olvida el `C:`. Tus archivos están en tu carpeta personal dentro de `/home`.
2.  **El Centro de Software es tu "Tienda":** No busques instaladores por internet. Todo el software profesional (Krita, OBS, Blender, Kdenlive) está a un clic en los repositorios oficiales.
3.  **Rendimiento Real:** Donde Windows se "atasca" con actualizaciones pesadas, Linux vuela. Es ideal para dar una segunda vida a portátiles de hace 5-8 años.
4.  **Libertad y Privacidad:** Tú tienes el control total del sistema. Sin actualizaciones forzadas ni publicidad en el menú de inicio.

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
