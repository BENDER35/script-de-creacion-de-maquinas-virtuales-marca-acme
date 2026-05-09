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
*   **22:45** - Corrección final de error GPG: Sustitución de la descarga directa de la llave (que devolvía 404) por la importación segura mediante **servidores de llaves (keyservers)**. Inclusión del repositorio de **backports** en Debian, requisito indispensable para la estabilidad de Fast Track.

## 2026-05-08 (Actualización de Logging y Documentación)
*   **23:10** - **Reforma del Sistema de Logging**: Se ha implementado un sistema de logging global que captura absolutamente toda la actividad del script (stdout y stderr) mediante redirección de flujo (`exec > >(tee ...)`) para asegurar la transparencia total en entornos educativos.
*   **23:15** - **Nuevo Formato de Reportes**: Cambio del nombre del archivo de log a `informe_imp_maqvirt(DD-MM-AAAA).log`. Se garantiza que cada ejecución genere un archivo nuevo (con timestamp si se repite en el mismo día) para evitar sobrescrituras y facilitar el seguimiento de laboratorios.
*   **23:25** - **Enfoque Pedagógico**: Actualización de la documentación técnica, el README y el historial para estudiantes de sistemas, ciberseguridad y programación, enfocándose en la trazabilidad, auditoría y automatización profesional.
*   **23:35** - **Ampliación Bibliográfica**: Se ha enriquecido la bibliografía con recursos avanzados sobre auditoría de sistemas, seguridad en el despliegue y buenas prácticas de programación en Bash.

## 2026-05-09
*   **12:15** - **Personalización de Credenciales**: Implementación de una nueva funcionalidad en el menú interactivo que permite al usuario elegir entre crear un usuario/contraseña personalizados o usar los valores predeterminados de administración segura (`root`/`toor`).
*   **12:20** - **Optimización del Setup en Chroot**: Refactorización de la lógica de creación de usuarios para manejar de forma inteligente la existencia previa del usuario (especialmente para el caso de `root`), asegurando que la configuración de `sudoers` y contraseñas sea coherente y segura.
*   **12:30** - **Actualización Documental Educativa**: Revisión completa de `DOCUMENTACION_TECNICA.md`, `README.md` y la bibliografía para orientarlos específicamente a estudiantes de sistemas, ciberseguridad y programación, integrando conceptos de gestión de identidad y autenticación básica.
*   **15:45** - **Corrección de Paquetes de Terceros (Flatpak/Snap/Extrepo)**: 
    *   **Flatpak**: Solución de errores de dependencia mediante la inclusión explícita de `bubblewrap`, esencial para el aislamiento (sandboxing) en entornos modernos.
    *   **Snap**: Mejora en la instalación de `snapd` mediante la adición de dependencias críticas como `dbus-user-session` y `squashfs-tools`, y manejo elegante de fallos en entornos chroot (donde el daemon de snap no puede ejecutarse).
    *   **Extrepo**: Refuerzo de la lógica de habilitación de repositorios externos con manejo de errores por repositorio.
    *   **Robustez de Sistema**: Implementación de `apt-get install -f` automático para reparar posibles corrupciones de paquetes durante la fase de provisión.
    *   **Optimización de Red**: Corrección de error sintáctico en la selección de mirrors (comparación de punto flotante en Bash) y normalización de locales para asegurar la detección del mirror más rápido.
