# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está pensada como guía avanzada para estudiantes de informática, migrantes de Windows y profesionales creativos que quieran optimizar su flujo de trabajo en Linux.

## 1. Arquitectura y Robustez (v1.7.3)

El script `create_vm.sh` implementa una lógica de construcción por capas, diseñada para resistir cambios en las distribuciones anfitrionas e invitadas.

*   **Sistema Anti-Bloqueo de Servicios (`policy-rc.d`):**
    1.  **El problema:** Al instalar paquetes como `ModemManager` o servidores de bases de datos dentro de un entorno `chroot`, el sistema intenta arrancar servicios mediante `systemd` o `dbus`. Como el `chroot` no tiene un sistema de inicio activo, el proceso de instalación se queda bloqueado indefinidamente esperando una señal de éxito que nunca llega.
    2.  **La solución:** Se ha implementado un mecanismo de control de políticas (`/usr/sbin/policy-rc.d`).
        -   Al inicio del `chroot`, se crea este script devolviendo el código de salida `101`.
        -   Ese código indica a los scripts post-instalación de Debian/Ubuntu que **no intenten arrancar el servicio**.
        -   Al finalizar la construcción, el archivo se elimina para permitir el funcionamiento normal de la VM en su primer arranque.
    *   **Log con colores:** El script implementa salida con colores para una mejor retroalimentación visual durante la ejecución (Rojo para errores, Amarillo para advertencias, Verde para información, Cyan para depuración).

*   **Gestión de Dependencias del Anfitrión:**
    Se usa una verificación triple para asegurar que herramientas críticas como `qemu-img` o `debootstrap` estén presentes, incluyendo sistemas de respaldo para paquetes virtuales en versiones modernas de Ubuntu. Los fallos al instalar dependencias del host ya no son fatales: el script avisa y continúa.

*   **Soporte QEMU:** Convierte imágenes RAW a formato QCOW2 para un almacenamiento eficiente y compatibilidad con KVM/libvirt.
*   **Soporte Vagrant:** Crea cajas Vagrant compatibles con el proveedor libvirt, incluyendo metadata.json y Vagrantfile para un despliegue sencillo.

*   **Sistema Snap Inteligente:**
    Implementa un servicio de "post-instalación diferida" (`acme-first-boot.service`) que resuelve la imposibilidad de instalar Snaps dentro de un `chroot` sin sistemas de archivos `squashfs` montados.

*   **Caché de Mirrors:**
    Almacena el mirror más rápido encontrado en la primera ejecución para acelerar las siguientes, reduciendo el tiempo de despliegue.

*   **Pruebas Paralelas de Mirrors:**
    Implementa testeo de red en paralelo para encontrar el mirror más rápido de una lista de candidatos, reduciendo notablemente el tiempo de selección. Kali y Parrot usan siempre sus mirrors oficiales.

*   **Soporte de Ubuntu Legacy:** El script permite crear máquinas virtuales de Ubuntu incluso en versiones que ya no tienen soporte oficial. Se puede especificar un codename personalizado y el script emitirá una advertencia si la versión no tiene soporte oficial.

*   **Selección de versión Debian:** El usuario puede elegir entre la rama estable actual (autodetectada), bookworm, bullseye, buster, testing o sid.

*   **Soporte Kali Linux:** El script puede construir máquinas virtuales con Kali Linux (Rolling), la distribución líder en pruebas de penetración. Soporta tipos de instalación (Default, Large, Everything, Headless, Core y Purple) y entornos de escritorio (XFCE, GNOME, KDE, MATE, LXDE, i3 y Enlightenment).

*   **Soporte Parrot Security (v1.7.3):** El script puede construir máquinas virtuales de la suite de seguridad **Parrot OS**. Soporta las ediciones **Security** (kit ofensivo completo, por defecto), **Home**, **Core** y **Hack The Box**, con los escritorios KDE, MATE, XFCE, GNOME e i3.

*   **Keyrings oficiales para derivados de Debian:** Para Kali y Parrot se descarga la clave oficial de firma de APT del fabricante (`archive.kali.org` y `deb.parrot.sh`) y se usa en dos puntos:
    1.  **`debootstrap --keyring`**, para verificar el sistema base durante el bootstrap.
    2.  **`/etc/apt/trusted.gpg.d`** dentro del invitado, para que `apt update` funcione sin avisos.
    Como las suites de Parrot y Kali no tienen script propio de `debootstrap`, el script reutiliza el de `sid` (Debian inestable), que es la base sobre la que se construyen.

## 2. Perfil de Orientación

### A. Estudiantes de Informática (SMR, ASIR, DAW/DAM, Ciberseguridad)
*   **Microinformática:** El script es un laboratorio vivo sobre la jerarquía de directorios de Linux (FHS) y la gestión de dispositivos loop.
*   **Sistemas:** El bloque de red demuestra el uso de `Netplan` y la transición desde las configuraciones heredadas de `/etc/network/interfaces`.
*   **Ciberseguridad:** Permite generar entornos de "Infraestructura como Código" (IaC) para laboratorios de Red Team / Blue Team, incluyendo estaciones completas de Kali y Parrot Security.

### B. Migrantes de Windows (Supervivencia y Eficiencia)
*   **Hardware Sostenible:** Linux permite que ordenadores antiguos con procesadores veteranos o sin chip TPM funcionen con fluidez, algo que Windows 11 prohíbe.
*   **Equivalencias de Software:** Se recomienda Flatpak para obtener versiones siempre actualizadas de navegadores y herramientas de oficina sin depender del sistema base.
*   **Versiones de Debian:** El script permite crear máquinas virtuales con distintas versiones de Debian: **12 (bookworm)** (estable actual), **11 (bullseye)** (estable anterior) y **10 (buster)** (estable antigua).

### C. Creativos: Diseño, Vídeo y Streaming (Economía de Recursos)
*   **Kernel de Baja Latencia:** El script facilita la instalación del sabor **Ubuntu Studio**, optimizando el kernel para evitar "jitter" o latencia en grabaciones de audio y retransmisiones en directo.
*   **Rendimiento de Vídeo:** Sin telemetría ni procesos antivirus pesados, Linux dedica más ciclos de CPU al renderizado en aplicaciones como **Blender** o **Kdenlive**.

## 3. Recursos Educativos y Técnicos

### Sistemas y Automatización
1.  **Manual del Administrador de Debian:** [Guía oficial de administración](https://debian-handbook.info/browse/stable/).
2.  **Vagrant Internals:** [Documentación de la arquitectura de cajas](https://www.vagrantup.com/docs/providers).
3.  **Referencia de Netplan:** [Configuración de red moderna en Ubuntu](https://netplan.io/reference/).
4.  **Estándar de Jerarquía del Sistema de Archivos:** [Especificación FHS 3.0](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).

### Multimedia y Producción
5.  **Guía de Audio de Ubuntu Studio:** [Wiki técnica sobre audio en Linux](https://ubuntustudio.org/manual/audio/).
6.  **Documentación de Krita:** [Manual para artistas digitales](https://docs.krita.org/es/).
7.  **Proyecto PipeWire:** [El futuro del audio y el vídeo en Linux](https://pipewire.org/).
8.  **Modo Estudio de OBS Studio:** [Documentación para streamers](https://obsproject.com/wiki/OBS-Studio-Overview).

### Iniciación y Transición
9.  **Linux Journey:** [Tutorial interactivo completo](https://linuxjourney.com/).
10. **AlternativeTo Linux:** [Buscador de equivalencias de programas](https://alternativeto.net/platform/linux/).
11. **DistroWatch:** [Base de datos de distribuciones Linux](https://distrowatch.com/).
12. **Arch Wiki:** Referencia técnica universal (también para usuarios de Debian/Ubuntu). [wiki.archlinux.org](https://wiki.archlinux.org/).

## 4. Lo Más Destacado del Historial (v1.7.3)

*   **Soporte Parrot Security:** Añadida la capacidad de crear máquinas virtuales de la suite de seguridad Parrot OS (ediciones Security, Home, Core y Hack The Box) con múltiples escritorios.
*   **Ediciones de Kali:** Añadido el selector de tipo de instalación (Default, Large, Everything, Headless, Core y Purple) y completada la lista de escritorios.
*   **Corrección crítica:** Reparado un error de sintaxis (un `fi` ausente) en el bloque de selección de escritorio que impedía que el script arrancara.
*   **Menú de escritorios rehecho:** El menú se genera limpiamente por distribución (Ubuntu/Debian/Kali/Parrot), eliminando opciones duplicadas y mal numeradas y la variable `$SKOLA` sin definir.
*   **Validación de argumentos:** Añadida validación para `--os` (ubuntu/debian/kali/parrot) y `--hyp`.
*   **Respeto del codename:** `fetch_latest_versions` ya no sobrescribe el codename elegido por el usuario.
*   **Sistema de caché de mirrors:** Añadido mecanismo de caché para almacenar el mirror más rápido, evitando testees redundantes.
*   **Pruebas paralelas de mirrors:** Selección optimizada limitando el testeo a los 10 mejores candidatos, reduciendo el tiempo en un 70% aproximadamente.
*   **Mejoras en la descarga de fondos:** Añadida lógica de reintentos y filtrado de formatos de imagen.
*   **Corrección de GRUB:** Solucionado un problema de expansión de variables donde `$1` dentro del script de chroot no pasaba correctamente el parámetro del dispositivo.
*   **Mejora de Flatpak:** Mejorada la detección de IDs de Flatpak para distinguir IDs completos de nombres de paquete.

## 5. Bibliografía y Recursos Educativos

Consulta la sección "Recursos Educativos y Técnicos" de arriba y la lista completa en `README.md`.
