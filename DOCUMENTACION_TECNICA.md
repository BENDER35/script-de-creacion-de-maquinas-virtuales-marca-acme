# Documentación Técnica: Creador de Máquinas Virtuales Marca Acme

Esta documentación detalla las funcionalidades avanzadas de automatización, personalización y diagnóstico implementadas en el script `create_vm.sh`.

## 1. Personalización Estética Avanzada (Multi-Búsqueda)

El script permite descargar una gran variedad de fondos de pantalla mediante la integración con la API de Wallhaven.

### Lógica de Multi-Búsqueda:
- **Entrada:** El usuario introduce términos separados por comas (ej: `espacio,cyberpunk,naturaleza`).
- **Procesamiento:** El script utiliza una matriz (`array`) de Bash y redefine el separador interno de campo (`IFS=','`) para iterar sobre cada búsqueda.
- **Volumen de Descarga:** Por cada término introducido, el script solicita 10 imágenes aleatorias en alta resolución (1920x1080), asegurando una biblioteca de fondos rica y variada dentro de la VM.

## 2. Gestión de Software y Paquetes Multi-Formato

El sistema es un orquestador universal capaz de manejar:
- **APT:** Procesamiento de listas por comas y conversión a argumentos de instalación.
- **Flatpak:** Configuración automática del motor y el repositorio Flathub.
- **Snap:** Gestión de pre-instalación de contenedores snapd.

## 3. Seguridad, Diagnóstico y Robustez

### Aislamiento de GRUB
Para proteger el host, se elimina físicamente `os-prober` y se desactiva explícitamente en la configuración de GRUB (`GRUB_DISABLE_OS_PROBER=true`). Esto garantiza que el cargador de la VM sea totalmente independiente, ignorando cualquier partición o sistema operativo presente en el equipo real.

### Auditoría de Logs y Errores
El script implementa una función `log` que redirige la salida a `stderr` (error estándar). Esto es una práctica profesional esencial por dos razones:
1.  **Limpieza de Datos:** Evita que los mensajes informativos se mezclen con el valor de retorno de las funciones (como la URL de un mirror).
2.  **Trazabilidad:** Permite un seguimiento detallado en `vm_creator.log` incluso cuando el script falla. El diagnóstico de códigos de salida (como el error 127 de "comando no encontrado") es ahora más sencillo gracias a la limpieza final de montajes.

## 4. Bibliografía y Recursos Educativos

1.  **Bash Arrays & IFS:** [Manipulación avanzada de listas en scripts](https://linuxconfig.org/how-to-use-arrays-in-bash).
2.  **Wallhaven API Reference:** [Automatización de recursos gráficos](https://wallhaven.cc/help/api).
3.  **Standard Streams (stdout/stderr):** [Entendiendo las salidas en Linux](https://www.gnu.org/software/bash/manual/html_node/Redirections.html).
4.  **Exit Codes Troubleshooting:** [Guía de códigos de error comunes](https://tldp.org/LDP/abs/html/exitcodes.html).
5.  **Multi-format Package Management:** [Estrategias para Flatpak y Snap](https://ubuntu.com/blog/snap-vs-flatpak).
6.  **Advanced debootstrap scripts:** [Creación de mirrors y fallbacks de versiones](https://wiki.debian.org/Debootstrap).
7.  **Partitioning with GNU Parted:** [Scripts para gestión de discos](https://www.gnu.org/software/parted/manual/parted.html).
8.  **Bash Traps & Cleanup:** [Gestión de señales y limpieza de emergencia](https://linuxcommand.org/lc3_wss0160.php).
9.  **JQ Processing for APIs:** [Extracción de datos JSON desde shell](https://stedolan.github.io/jq/manual/).
10. **VirtualBox CLI Reference:** [Gestión de hardware virtual](https://www.virtualbox.org/manual/ch08.html).
