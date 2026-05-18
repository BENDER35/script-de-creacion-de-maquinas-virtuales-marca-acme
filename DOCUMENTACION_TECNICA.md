# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para servir como guía avanzada para estudiantes de **IT**, **migrantes de Windows** y **profesionales creativos** que buscan optimizar su flujo de trabajo en Linux.

## 1. Arquitectura y Robustez (v1.7.0)

El script `create_vm.sh` implementa una lógica de construcción por capas, diseñada para ser resiliente a los cambios en las distribuciones host y guest.

*   **Sistema Anti-Bloqueo de Servicios (`policy-rc.d`):**
    1.  **El Problema:** Al instalar paquetes como `ModemManager` o servidores de bases de datos dentro de un entorno `chroot`, el sistema intenta arrancar servicios a través de `systemd` o `dbus`. Dado que el entorno `chroot` no tiene un sistema de init activo, el proceso de instalación se bloquea indefinidamente esperando una señal de éxito que nunca llega.
    2.  **La Solución:** Se ha implementado un mecanismo de control de políticas (`/usr/sbin/policy-rc.d`). 
        -   Al inicio del chroot, se crea este script devolviendo el código `101`.
        -   Este código indica a los scripts de post-instalación de Debian/Ubuntu que **no deben intentar arrancar el servicio**.
        -   Al finalizar la construcción, el archivo se elimina para permitir el funcionamiento normal del sistema una vez arrancada la VM.

*   **Gestión de Dependencias en el Host:** 
    Se utiliza una lógica de triple verificación para asegurar que herramientas críticas como `qemu-img` o `debootstrap` estén presentes, incluyendo sistemas de fallback para paquetes virtuales en versiones modernas de Ubuntu.

*   **Sistema Smart Snap:** 
    Implementa un servicio de "post-instalación diferida" (`acme-first-boot.service`) que soluciona la imposibilidad de instalar Snaps dentro de un `chroot` sin los sistemas de archivos `squashfs` montados.

## 2. Guía de Orientación por Perfiles

### A. Estudiantes de IT (SMR, ASIR, DAW/DAM, Ciberseguridad)
*   **Microinformática:** El script es un laboratorio viviente sobre la jerarquía de directorios Linux (FHS) y la gestión de dispositivos loop.
*   **Sistemas:** El bloque de red demuestra el uso de `Netplan` y la transición desde configuraciones heredadas de `/etc/network/interfaces`.
*   **Ciberseguridad:** Permite generar entornos de "Infraestructura como Código" (IaC) para laboratorios de Red Team / Blue Team.

### B. Migrantes desde Windows (Supervivencia y Eficiencia)
*   **Hardware Sostenible:** Linux permite que ordenadores con procesadores antiguos o sin chips TPM funcionen de forma fluida, algo que Windows 11 prohíbe.
*   **Equivalencias de Software:** Se recomienda el uso de **Flatpak** para obtener versiones siempre actualizadas de navegadores y herramientas de oficina sin depender del sistema base.

### C. Creativos: Diseño, Vídeo y Streaming (Economía de Recursos)
*   **Kernel de Baja Latencia:** El script facilita la instalación del sabor **Ubuntu Studio**, optimizando el kernel para evitar el "jitter" o latencia en grabaciones de audio y streamings en vivo.
*   **Rendimiento en Vídeo:** Al no tener procesos de telemetría o antivirus pesados, Linux dedica más ciclos de CPU al renderizado en aplicaciones como **Blender** o **Kdenlive**.

## 3. Bibliografía y Recursos Educativos

### Sistemas y Automatización
1.  **The Debian Administrator's Handbook:** [Guía oficial de administración](https://debian-handbook.info/browse/stable/).
2.  **Vagrant Internals:** [Documentación de arquitectura de boxes](https://www.vagrantup.com/docs/providers).
3.  **Netplan Reference:** [Configuración de red moderna en Ubuntu](https://netplan.io/reference/).
4.  **Filesystem Hierarchy Standard:** [FHS 3.0 Specification](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).

### Multimedia y Producción
5.  **Ubuntu Studio Audio Guide:** [Wiki técnica sobre audio en Linux](https://ubuntustudio.org/manual/audio/).
6.  **Krita Documentation:** [Manual para artistas digitales](https://docs.krita.org/es/).
7.  **PipeWire Project:** [El futuro del audio y vídeo en Linux](https://pipewire.org/).
8.  **OBS Studio Studio Mode:** [Documentación para streamers](https://obsproject.com/wiki/OBS-Studio-Overview).

### Iniciación y Transición
9.  **Linux Journey:** [Tutorial interactivo completo](https://linuxjourney.com/).
10. **AlternativeTo Linux:** [Buscador de equivalencias de programas](https://alternativeto.net/platform/linux/).
11. **DistroWatch:** [Base de datos de distribuciones Linux](https://distrowatch.com/).
12. **Arch Wiki:** Referencia técnica universal (incluso para usuarios de Debian/Ubuntu). [wiki.archlinux.org](https://wiki.archlinux.org/).
