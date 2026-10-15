# VM-Acme: Generador de Laboratorios Virtuales para FP y Universidad

![Version](https://img.shields.io/badge/version-1.9.0-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Creativos-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu/Kali/Parrot/MX Linux/Linux Mint/LMDE) personalizadas de forma totalmente automatizada. Es un recurso pedagógico y profesional diseñado para democratizar el acceso a la tecnología, ideal para quienes buscan una alternativa potente y gratuita a los sistemas propietarios.

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

## 🚀 Características Principales (v1.9.0)

*   **Sistema Anti-Bloqueo `policy-rc.d`:** Garantiza que la instalación nunca se detenga por servicios rebeldes (como `ModemManager`). **Estabilidad absoluta en Hyper-V y entornos virtualizados**. Incorpora **registro con colores** para una mejor retroalimentación visual durante la ejecución (Rojo para errores, Amarillo para advertencias, Verde para info, Cyan para modo debug).
*   **Gestión Inteligente de Dependencias:** Detección de paquetes virtuales y proveedores de fallback (ej: `qemu-user-binfmt`).
*   **Multi-Formato Profesional:** Soporte para **VirtualBox**, **VMware**, **QEMU**, **RAW**, **RootFS**, **Vagrant** e **Hyper-V**.
*   **Soporte QEMU:** Convierte imágenes RAW a formato QCOW2 para un almacenamiento virtual eficiente y compatibilidad con KVM/libvirt.
*   **Soporte Vagrant:** Crea cajas Vagrant con metadata.json y Vagrantfile para el proveedor libvirt/KVM.

*   **Instalación Inteligente de Snaps:** Detección automática de requerimientos `--classic` para software creativo.
*   **Caché de Mirrors:** Sistema de caché para almacenar el mirror más rápido encontrado, evitando testees redundantes en ejecuciones subsiguientes.
*   **Pruebas Paralelas de Mirrors:** Optimización del testeo de mirrors reduciendo el número de candidates de 20 a 10, reduciendo el tiempo de selección en aproximadamente un 70%.
*   **Soporte de Ubuntu Legacy:** Permite crear máquinas virtuales de Ubuntu incluso en versiones que ya no tienen soporte oficial. El script permite especificar un codename personalizado y emite una advertencia si la versión no tiene soporte oficial.
*   **Soporte Kali Linux:** Permite crear máquinas virtuales con Kali Linux, la distribución líder en pruebas de penetración. Selección de tipo de instalación (Default, Large, Everything, Headless, Core y **Purple** —la variante defensiva con herramientas de detección, respuesta y recuperación—) y de escritorios (XFCE, GNOME, KDE, MATE, LXDE, i3 y Enlightenment).
*   **Soporte Parrot Security:** Permite crear máquinas virtuales de la suite de seguridad **Parrot OS**. Incluye las ediciones **Security** (kit ofensivo completo, por defecto), **Home**, **Core** y **Hack The Box**, con los escritorios KDE, MATE, XFCE, GNOME e i3. Descarga e instala automáticamente el keyring oficial de Parrot.
*   **Soporte MX Linux:** Permite crear máquinas virtuales de **MX Linux** (basado en Debian Stable, actualmente _trixie_), una de las distribuciones más populares y ligeras del panorama Linux. Incluye las ediciones **XFCE** (predeterminada), **KDE Plasma**, **Fluxbox** y **AHS** (Advanced Hardware Support), y escritorios XFCE, KDE, Fluxbox, MATE, GNOME, Cinnamon y LXQt. Añade automáticamente el repositorio de la comunidad (mxrepo.com), descarga e integra el keyring oficial `mx25-archive-keyring` y despliega las herramientas y aplicaciones propias de MX (`mx-system`, `mx-tools`, `mx-welcome`, `mx25-artwork`, `mx-apps`).
*   **Keyrings oficiales de Kali y Parrot:** El script obtiene e integra las claves de firma oficiales de estos derivados de Debian (tanto en `debootstrap` como en el sistema invitado) para que APT funcione sin avisos.
*   **Keyring oficial de MX Linux:** Descarga el paquete `mx25-archive-keyring`, extrae la clave de firma y la integra en el sistema invitado (`/etc/apt/trusted.gpg.d` y `/usr/share/keyrings`) para validar el repositorio de mxrepo.com.
*   **Soporte Linux Mint (`mint`):** Crea máquinas virtuales de **Linux Mint** (base Ubuntu 24.04 _noble_), la distribución de escritorio más popular y amigable para quienes vienen de Windows. Incluye las ediciones **Cinnamon** (predeterminada), **MATE** y **XFCE**. Añade automáticamente el repositorio oficial de Mint (`packages.linuxmint.com`) junto al de Ubuntu, descarga e integra el keyring `linuxmint-keyring` y despliega los metapaquetes `mint-meta-core`, `mint-meta-codecs` y `mint-meta-<escritorio>`.
*   **Soporte Linux Mint Debian Edition (`lmde`):** Crea máquinas virtuales de **LMDE 7 "Gigi"** (base Debian 13 _trixie_), la variante de Linux Mint sin dependencia de Ubuntu. Incluye la edición **Cinnamon** (predeterminada) y la opción de XFCE/MATE mediante los task de Debian. Añade el repositorio de Mint, su keyring y los paquetes base de Mint.
*   **Soporte de red para Linux Mint y LMDE:** Al igual que MX Linux, las ediciones de Mint instalan y configuran **NetworkManager** para gestionar la red desde el primer arranque.
*   **Selección de versión Debian:** Permite elegir entre la versión estable actual, bookworm, bullseye, buster, testing o sid.

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

# Ejemplo: Crear un laboratorio de pentesting con Parrot Security
sudo ./create_vm.sh --name lab_pentest --os parrot --edition security --desktop kde --ram 4096

# Ejemplo: Crear una estación de trabajo ligera con MX Linux
sudo ./create_vm.sh --name escritorio_mx --os mx --edition xfce --desktop mx-xfce --ram 2048

# Ejemplo: Crear un escritorio Linux Mint (Cinnamon) para migrar desde Windows
sudo ./create_vm.sh --name escritorio_mint --os mint --desktop mint-cinnamon --ram 3072

# Ejemplo: Crear un escritorio LMDE 7 (Debian Edition) con Cinnamon
sudo ./create_vm.sh --name escritorio_lmde --os lmde --desktop lmde-cinnamon --ram 3072

# Ejemplo: Crear un laboratorio defensivo con Kali Linux Purple
sudo ./create_vm.sh --name lab_purple --os kali --edition purple --desktop kali-xfce --ram 4096
```

## 📚 Bibliografía y Recursos de Aprendizaje

### 🛠️ Tecnología y Sistemas
1.  **Manual del Administrador de Debian:** La guía definitiva para entender el sistema. [debian-handbook.info](https://debian-handbook.info/browse/stable/).
2.  **Linux Journey:** Un curso estructurado desde lo más básico hasta la administración de servidores. [linuxjourney.com](https://linuxjourney.com/).
3.  **Documentación de Vagrant:** Aprende a automatizar tus laboratorios de pruebas. [vagrantup.com/docs](https://www.vagrantup.com/docs).
4.  **Documentación de QEMU:** Entiende cómo funciona la emulación de hardware. [qemu.org/docs](https://qemu.org/docs/master/).

### 🎨 Creación Multimedia y Diseño
5.  **Manual de Krita:** Manual profesional para artistas digitales. [docs.krita.org](https://docs.krita.org/).
6.  **Manual de Ubuntu Studio:** Guía para configurar un sistema de producción multimedia de alto nivel. [ubuntustudio.org/manual/](https://ubuntustudio.org/manual/).
7.  **Fundamentos de Blender:** Aprende el estándar de la industria 3D. [docs.blender.org](https://docs.blender.org/manual/es/latest/).
8.  **Manual de Usuario de Kdenlive:** Edición de vídeo profesional paso a paso. [docs.kdenlive.org](https://docs.kdenlive.org/).

### 🐧 Transición y Cultura Digital
9.  **AlternativeTo Linux:** Busca las mejores alternativas libres a tus programas de Windows. [alternativeto.net](https://alternativeto.net/platform/linux/).
10. **It's FOSS:** El mejor blog para principiantes que quieren consejos prácticos. [itsfoss.com](https://itsfoss.com/).
11. **DistroSea:** Prueba Linux en tu navegador sin instalar nada. [distrosea.com](https://distrosea.com/).
12. **Fundación Software Libre (FSF):** Aprende sobre la importancia ética del software libre. [fsf.org](https://www.fsf.org/).

---

*Este proyecto es una herramienta de resistencia digital, diseñada para que nadie se quede atrás por motivos económicos o falta de acceso a hardware costoso.*