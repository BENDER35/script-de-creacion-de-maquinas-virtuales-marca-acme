# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

## 2026-05-06
*   **22:12** - Inicio del proyecto. Primera versión del script orientada a Ubuntu 26.04.
*   **22:26** - Implementación de la creación de ISOs de configuración (CIDATA) para autoinstalación en Ubuntu.
*   **23:44** - Mejora en la detección de dependencias del host, añadiendo soporte para `binfmt-support`.
*   **23:53** - Optimización de la selección de mirrors para acelerar la descarga de paquetes.

## 2026-05-07
*   **00:02** - Implementación del menú interactivo para facilitar la configuración al usuario.
*   **00:13** - Introducción de la fase CHROOT para una configuración más profunda del sistema invitado.
*   **00:31** - Añadida funcionalidad de conversión de disco a formato VDI (VirtualBox) y registro automático en el hipervisor.
*   **00:53** - Implementación de la descarga automática de fondos de pantalla desde la API de Wallhaven.
*   **01:25** - Refactorización del código para mejorar la legibilidad y el manejo de errores (códigos de salida).
*   **02:00** - Inclusión de soporte para compresión en formatos ZIP, RAR y 7Z del resultado final.

## 2026-05-08
*   **19:39** - Primera implementación del soporte para Debian (Trixie).
*   **20:54** - Identificación de problemas críticos en la instalación de `virtualbox-guest-tools` en Debian Trixie (paquetes no encontrados en repositorios estándar).
*   **21:15** - Solución del problema de VirtualBox Tools en Debian mediante la integración del repositorio **Fast Track**.
*   **21:30** - Actualización exhaustiva de la documentación técnica y el manual de usuario (README).
*   **22:10** - Mejora de la seguridad GPG: Implementación del método manual `signed-by` para el repositorio Fast Track. Se añadió soporte para `gnupg` en el entorno chroot y se documentaron diversas formas de gestión de llaves para fines educativos en sistemas y ciberseguridad.
*   **22:45** - **(Actual)** Corrección final de error GPG: Sustitución de la descarga directa de la llave (que devolvía 404) por la importación segura mediante **servidores de llaves (keyservers)**. Inclusión del repositorio de **backports** en Debian, requisito indispensable para la estabilidad de Fast Track.
