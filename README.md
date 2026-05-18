# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.7.0-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Creativos-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es un recurso pedagógico y profesional diseñado para democratizar el acceso a la tecnología, ideal para quienes buscan una alternativa potente y gratuita a los sistemas propietarios.

## 🎯 Perfiles de Usuario

*   **Estudiantes de Sistemas, Programación, Ciberseguridad y Microinformática:** 
    *   **Iniciación (SMR/ASIR):** Aprende cómo se construye un sistema operativo desde sus cimientos. El script es una lección abierta sobre particionado, montajes y gestión de paquetes.
    *   **Laboratorios de Redes:** Genera infraestructuras completas en segundos para practicar routing, firewalling o pentesting.
    *   **Automatización (DAW/DAM):** Estudia el código fuente para dominar Bash y la infraestructura como código (IaC).
*   **Migrantes de Windows (Hogar y Oficina):** 
    *   **Transición Segura:** No rompas tu ordenador principal. Crea máquinas virtuales para aprender Linux, su terminal y su filosofía de libertad sin riesgos.
    *   **Privacidad Total:** Olvídate del rastreo de datos y las actualizaciones forzosas que ralentizan tu trabajo.
*   **Creativos (Diseño, Ilustración, Vídeo y Streaming):** 
    *   **Alternativa Económica:** Si no puedes permitirte las suscripciones mensuales de Adobe o tu hardware no soporta Windows 11, Linux es tu salvación.
    *   **Hardware Antiguo:** Dale una segunda vida a ese equipo que Windows considera "obsoleto". Linux vuela donde otros sistemas se arrastran.
    *   **Software Profesional:** Usa **Krita** para ilustración, **Blender** para 3D, **Kdenlive** para edición de vídeo y **OBS Studio** para tus directos.

## 🚀 Características Principales (v1.7.0)
*   **Sistema Anti-Bloqueo `policy-rc.d`:** Garantiza que la instalación nunca se detenga por servicios rebeldes (como `ModemManager`). Estabilidad absoluta en Hyper-V y entornos virtualizados.
*   **Gestión Inteligente de Dependencias:** Detección de paquetes virtuales y proveedores de fallback (ej: `qemu-user-binfmt`).
*   **Multi-Formato Profesional:** Soporte para **VirtualBox**, **VMware**, **QEMU**, **RAW**, **RootFS**, **Vagrant** e **Hyper-V**.
*   **Instalación Inteligente de Snaps:** Detección automática de requerimientos `--classic` para software creativo.

## 📘 Guía para Principiantes y Profesionales

### 🎓 Estudiantes de IT
- **Ciberseguridad:** Crea máquinas "víctima" y "atacante" con configuraciones de red aisladas.
- **Microinformática:** Observa cómo `debootstrap` instala solo lo necesario. Es la base para entender el "minimalismo" informático.

### 🪟 Si vienes de Windows
- **Software Equivalente:** Usa **LibreOffice** por Office, **GIMP** por Photoshop y **Inkscape** por Illustrator. La mayoría son gratuitos y de código abierto.
- **Instalación Segura:** Aquí no descargas archivos ".exe" extraños. Todo viene de repositorios verificados por la comunidad.

### 🎨 Creativos y Streamers
- **Ilustración:** Conecta tu tableta gráfica (Wacom, Huion, XP-Pen) y abre **Krita**. La gestión de presión y color es asombrosa.
- **Edición de Vídeo:** **Kdenlive** permite editar en 4K con proxies, ideal si tu equipo tiene pocos recursos.
- **Streaming:** **OBS Studio** en Linux consume menos CPU, permitiendo que tus juegos o aplicaciones de diseño funcionen mejor mientras emites.

## 🛠️ Guía de Inicio Rápido
```bash
# Ejemplo: Crear una máquina para un estudiante de redes
sudo ./create_vm.sh --name lab_redes --os debian --ram 1024 --desktop none --apt nmap,tcpdump

# Ejemplo: Crear una estación para un ilustrador digital
sudo ./create_vm.sh --name estudio_arte --os ubuntu --desktop xfce --apt krita,gimp,inkscape
```

## 📚 Bibliografía y Recursos de Aprendizaje

### 🛠️ Tecnología y Sistemas
1.  **Debian Administrator's Handbook:** La guía definitiva para entender el sistema. [debian-handbook.info](https://debian-handbook.info/browse/stable/).
2.  **Linux Journey:** Un curso estructurado desde lo más básico hasta la administración de servidores. [linuxjourney.com](https://linuxjourney.com/).
3.  **Vagrant Docs:** Aprende a automatizar tus laboratorios de pruebas. [vagrantup.com/docs](https://www.vagrantup.com/docs).
4.  **QEMU Documentation:** Entiende cómo funciona la emulación de hardware. [qemu.org/docs](https://www.qemu.org/docs/master/).

### 🎨 Creación Multimedia y Diseño
5.  **Krita Manual:** Manual profesional para artistas digitales. [docs.krita.org](https://docs.krita.org/).
6.  **Ubuntu Studio Manual:** Guía para configurar un sistema de producción multimedia de alto nivel. [ubuntustudio.org/manual/](https://ubuntustudio.org/manual/).
7.  **Blender Fundamentals:** Aprende el estándar de la industria 3D. [docs.blender.org](https://docs.blender.org/manual/es/latest/).
8.  **Kdenlive User Manual:** Edición de vídeo profesional paso a paso. [docs.kdenlive.org](https://docs.kdenlive.org/).

### 🐧 Transición y Cultura Digital
9.  **AlternativeTo Linux:** Busca las mejores alternativas libres a tus programas de Windows. [alternativeto.net](https://alternativeto.net/platform/linux/).
10. **It's FOSS:** El mejor blog para principiantes que quieren consejos prácticos. [itsfoss.com](https://itsfoss.com/).
11. **DistroSea:** Prueba Linux en tu navegador sin instalar nada. [distrosea.com](https://distrosea.com/).
12. **Free Software Foundation (FSF):** Aprende sobre la importancia ética del software libre. [fsf.org](https://www.fsf.org/).

---
*Este proyecto es una herramienta de resistencia digital, diseñada para que nadie se quede atrás por motivos económicos o falta de acceso a hardware costoso.*
