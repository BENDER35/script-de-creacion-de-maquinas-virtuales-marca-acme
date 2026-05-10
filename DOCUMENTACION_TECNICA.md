# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas**, **Ciberseguridad** y **Programación** que deseen entender cómo orquestar la creación de entornos Linux de forma profesional.

## 1. Arquitectura del Script (Perspectiva de Programación)

El script `create_vm.sh` utiliza un enfoque modular y robusto basado en Bash:

*   **Gestión de Errores (Error Handling):** Se utiliza `set -e` y `set -o pipefail` para detener la ejecución ante cualquier fallo, y un `trap` de limpieza (`cleanup`) para liberar recursos (montajes, dispositivos loop).
*   **Inyección de Variables y Generación Dinámica:** Una técnica avanzada utilizada es la generación del script de provisión (`setup.sh`) mediante *Heredocs*. Para evitar errores de expansión de variables dentro del entorno `chroot`, la lógica de decisión (como qué paquetes instalar) se ejecuta en el **Host**. Esto garantiza que el script generado sea estático y predecible, una práctica recomendada en el desarrollo de herramientas de automatización.
*   **Logging Avanzado:** Sistema de logs con niveles (`INFO`, `DEBUG`, etc.) y captura de flujos de salida de subprocesos, esencial para la trazabilidad en sistemas complejos.

## 2. Gestión de Paquetes Modernos (Sistemas y Programación)

El script integra tres de las tecnologías más relevantes para la distribución de software moderno, cada una con un enfoque pedagógico distinto:

### Flatpak: Aislamiento y Portabilidad
*   **Concepto:** Flatpak utiliza contenedores para ejecutar aplicaciones, lo que garantiza que funcionen igual en cualquier distribución.
*   **Implementación Técnica:** Para que Flatpak funcione, es imprescindible el paquete `bubblewrap`. Este utiliza *namespaces* del kernel Linux para crear el entorno aislado. 
*   **Lección para Estudiantes:** El fallo en la instalación de Flatpak suele deberse a la falta de `bubblewrap`. Al incluirlo explícitamente, aseguramos que el "sandbox" pueda inicializarse correctamente.

### Snap: Servicios y Ecosistema Ubuntu
*   **Concepto:** Promovido por Canonical, Snap permite paquetes autogestionados que incluyen todas sus dependencias.
*   **Desafío en Chroot:** Snap requiere el daemon `snapd` corriendo bajo `systemd`. En un entorno de construcción `chroot`, el daemon no está activo. 
*   **Solución Aplicada:** El script instala `snapd`, `dbus-user-session` y `squashfs-tools` (necesario para montar las imágenes de los snaps). Aunque la ejecución de `snap install` puede dar advertencias en chroot, los paquetes quedan preparados para el primer arranque.

### Extrepo: Gestión Curada de Repositorios Externos
*   **Concepto:** Una herramienta de Debian para habilitar repositorios de terceros (como VSCode, Signal, etc.) de forma segura y verificada.
*   **Ventaja en Ciberseguridad:** Evita que el usuario tenga que descargar scripts `curl | sudo bash` inseguros, proporcionando una vía oficial y firmada para software externo.

## 3. Administración de Sistemas (Infraestructura como Código)

*   **Gestión de Repositorios y Drivers:** Para sistemas como Debian, es crucial configurar no solo los repositorios `main`, sino también `contrib`, `non-free` y los repositorios de **seguridad**.
*   **Gestión de Identidad y Autenticación:** El script permite la creación de usuarios personalizados o el uso de una cuenta de superusuario (`root`) preconfigurada. Desde el punto de vista de la administración de sistemas, esto enseña la diferencia entre el uso de `sudo` para tareas administrativas (recomendado en producción) y el acceso directo como root (común en entornos de laboratorio o "hack boxes").
*   **Debian Fast Track:** En versiones recientes de Debian (como 12 Bookworm o 13 Trixie), las herramientas de invitado de VirtualBox pueden no estar presentes en los repositorios estándar debido a ciclos de lanzamiento. El script integra automáticamente el repositorio **Fast Track**, un proyecto oficial de Debian que proporciona paquetes actualizados (backports) de software como VirtualBox para garantizar la compatibilidad de drivers.
*   **Repositorio Backports:** Requisito indispensable para Fast Track. El script habilita automáticamente los backports oficiales de Debian para asegurar que las dependencias de bajo nivel estén satisfechas.
*   **Compilación de Módulos (DKMS):** El script automatiza la instalación de `linux-headers`, `build-essential` y `dkms` cuando se detecta VirtualBox. Esto es vital para que los drivers del invitado se compilen correctamente contra el kernel instalado en el entorno `chroot`.

## 3. Seguridad y Confianza: Gestión de Llaves GPG y Credenciales

### Gestión de Credenciales (Ciberseguridad):
En un entorno de aprendizaje de ciberseguridad, el manejo de credenciales es crítico:
*   **Aprovisionamiento Seguro:** El script utiliza `chpasswd` para establecer contraseñas de forma no interactiva dentro del chroot. Esto evita que las contraseñas aparezcan en el historial de comandos del sistema invitado.
*   **Principio de Mínimo Privilegio:** Cuando se crea un usuario normal, se le otorgan permisos de `sudo` sin contraseña para facilitar el aprendizaje, pero se documenta que en entornos reales esto debe ser restringido.
*   **Uso de root/toor:** La opción por defecto `root/toor` es una convención clásica en distribuciones de seguridad (como Kali Linux en sus inicios), permitiendo a los estudiantes enfocarse en la herramienta antes que en la gestión de permisos.

### Gestión de llaves GPG (Educativo):
La autenticidad de los paquetes se garantiza mediante criptografía de clave pública (GPG). Cuando añadimos un repositorio externo como **Fast Track**, debemos "decirle" a APT que confíe en él.

#### Métodos para agregar llaves GPG (Educativo):

1.  **Añadido Manual (Recomendado/Moderno):**
    *   **Proceso:** Se descarga la llave pública, se desprotege (`gpg --dearmor`) y se guarda en `/usr/share/keyrings/`.
    *   **Ventaja:** Permite usar la opción `[signed-by=...]` en el archivo `.list`, lo que limita la confianza de esa llave *solo* a ese repositorio específico (principio de mínimo privilegio).
    *   **Ejemplo en el script:** `wget -qO- [URL_KEY] | gpg --dearmor -o /usr/share/keyrings/mi-repo.gpg`

2.  **Paquete de Keyring (Oficial):**
    *   **Proceso:** Instalar un paquete `.deb` que contiene las llaves (ej: `fasttrack-archive-keyring`).
    *   **Ventaja:** Las llaves se actualizan automáticamente cuando el proyecto las renueva a través de `apt upgrade`.

3.  **Método Heredado (Deprecated):**
    *   **Comando:** `apt-key add`.
    *   **Riesgo:** Añade la llave a un llavero global compartido (`/etc/apt/trusted.gpg`), lo que significa que esa llave podría validar paquetes de *cualquier* repositorio, comprometiendo la seguridad global si la llave es vulnerada.

## 4. Validación de Entradas y Robustez (Programación y Sistemas)

En el desarrollo de herramientas de automatización, la validación de la entrada del usuario es un pilar fundamental tanto para la **Programación** (evitar bugs) como para la **Ciberseguridad** (evitar inyecciones o estados inesperados).

### Validación de Unidades de Almacenamiento
*   **Problema Detectado:** Herramientas como `qemu-img` interpretan valores numéricos puros como bytes. Si un usuario introduce "70" esperando Gigabytes, se crea un archivo de 70 bytes, lo que provoca fallos catastróficos en el particionado.
*   **Solución Técnica:** El script implementa una expresión regular (`^[0-9]+$`) para detectar entradas sin sufijo. Si se detecta un número puro, el script realiza una **asunción segura** y añade el sufijo "G".
*   **Lección para Estudiantes:** Siempre se debe validar que los datos de entrada cumplan con el formato esperado por las herramientas de bajo nivel para garantizar la estabilidad del sistema.

### Sanitización de Consultas API
*   **Problema Detectado:** Al procesar listas separadas por comas, es común que se introduzcan saltos de línea o espacios accidentales. Al codificar estos caracteres para una URL (URL Encoding), un salto de línea se convierte en `%0A`, lo que invalida la consulta a la API de Wallhaven.
*   **Solución Técnica:** Se utiliza `xargs` para limpiar espacios en blanco y `echo -n` para asegurar que el flujo hacia `jq` no contenga caracteres de control invisibles.
*   **Lección para Estudiantes:** La sanitización de flujos de datos es crítica cuando se interactúa con servicios externos (APIs) para prevenir comportamientos erráticos.

## 5. debootstrap y Repositorios con Firma

Cuando usamos `debootstrap` para crear una máquina desde cero, el comando verifica la firma del repositorio principal usando el llavero del sistema host (`/usr/share/keyrings/debian-archive-keyring.gpg`).

Si quisiéramos incluir un repositorio externo *durante* el proceso inicial de debootstrap (antes del chroot), podríamos usar la opción:
`--keyring=/ruta/a/mi/llave.gpg`

Sin embargo, la práctica estándar en despliegues automatizados es realizar un bootstrap mínimo y configurar los repositorios adicionales en la fase de **provisión** (dentro del chroot), como hace nuestro script.

## 5. Guía de Uso por Parámetros

```bash
sudo ./create_vm.sh --name "servidor_web" --os debian --ram 1024 --desktop none --verbose
```

### Tabla de Parámetros:
| Parámetro | Descripción | Defecto |
| :--- | :--- | :--- |
| `--name` | Nombre de la máquina virtual | acme\_vm\_[timestamp] |
| `--os` | Distribución (ubuntu/debian) | ubuntu |
| `--hyp` | Hypervisor (vbox/vmware/qemu) | vbox |
| `--ram` | Memoria RAM en Megabytes | 2048 |
| `--disk` | Tamaño del disco (ej: 50G) | 50G |
| `--cpucores` | Número de núcleos de CPU | 2 |
| `--desktop` | Entorno de escritorio | none |

## 6. Personalización de Hardware y Sabores (Sistemas y Microinformática)

Para estudiantes de **Microinformática** y **Sistemas**, entender la asignación de recursos es fundamental:
*   **Gestión de CPUs:** El parámetro `--cpucores` permite simular entornos multiprocesador, permitiendo estudiar el rendimiento de aplicaciones multihilo en sistemas Linux.
*   **Dimensionamiento de Recursos:** La capacidad de definir el RAM y el Disco desde el menú interactivo enseña a los estudiantes a equilibrar las necesidades del sistema operativo con los recursos físicos disponibles en el host.
*   **Edubuntu y Cinnamon (Sabores):** La inclusión del sabor educativo **Edubuntu** (`gnome(edub.)`) y el elegante entorno **Cinnamon** (`cinnamon(ub)`) permite a los estudiantes comparar diferentes paradigmas de escritorio y requisitos de recursos en sistemas modernos.

## 7. Registro de Cambios (Changelog Educativo)

*   **v1.7 - Soporte para Ubuntu Cinnamon:** Integración del entorno de escritorio Cinnamon para Ubuntu, mejorando la oferta de sabores disponibles para laboratorios de microinformática.
*   **v1.6 - Personalización de Hardware:** Introducción de control sobre núcleos de CPU, RAM y tamaño de disco, junto con soporte para el sabor educativo Edubuntu.
*   **v1.5 - Gestión de Identidades:** Implementación de selección dinámica de credenciales (Usuario/Pass vs root/toor) con lógica de detección de usuarios existentes.
*   **v1.4 - Transparencia Total:** Implementación de logging global mediante redirección de descriptores de archivo. Los logs ahora incluyen fecha en el nombre y rotación automática para sesiones múltiples.
*   **v1.3 - Refuerzo de Seguridad GPG:** Implementación del método `signed-by` para el repositorio Fast Track. Se añadió soporte para `gnupg` en el entorno chroot.
*   **v1.2 - Integración Fast Track:** Solución para la instalación de VirtualBox Guest Tools en Debian mediante el repositorio `fasttrack.debian.net`.

## 7. Bibliografía y Recursos Educativos Ampliados

### Documentación Oficial y Técnica:
1.  **Debian Fast Track Project:** [Paquetes actualizados para Debian Stable](https://fasttrack.debian.net/).
2.  **Debian Wiki - VirtualBox Guest Additions:** [Guía oficial de instalación](https://wiki.debian.org/VirtualBox/GuestAdditions).
3.  **Debian debootstrap Wiki:** [Creación de sistemas base](https://wiki.debian.org/Debootstrap).
4.  **Apt-Key Deprecation:** [Explicación sobre el fin de apt-key y el uso de signed-by](https://wiki.debian.org/DebianRepository/UseThirdParty).
5.  **GNU Privacy Guard (GnuPG):** [Manual oficial de GPG](https://gnupg.org/documentation/manuals/gnupg/).
6.  **DKMS Project Documentation:** [Dynamic Kernel Module Support](https://github.com/dell/dkms).
7.  **Linux Kernel Headers:** [Por qué son necesarios para compilar módulos](https://kernelnewbies.org/KernelHeaders).
8.  **Bash Manual - Redirections:** [Explicación detallada de descriptores de archivo y pipes](https://www.gnu.org/software/bash/manual/html_node/Redirections.html).
9.  **QEMU Documentation:** [Formatos de imagen de disco](https://www.qemu.org/docs/master/system/images.html).

### Administración de Usuarios y Seguridad:
10. **Debian Wiki - SystemGroups:** [Entendiendo los grupos y privilegios en Debian](https://wiki.debian.org/SystemGroups).
11. **Sudoers Manual:** [Configuración avanzada del archivo sudoers](https://www.sudo.ws/docs/man/sudoers.man/).
12. **Shadow Passwords:** [Cómo Linux gestiona las contraseñas de forma segura](https://tldp.org/HOWTO/Shadow-Password-HOWTO.html).
13. **The Linux Documentation Project - Security Guide:** [Principios de seguridad en Linux](https://tldp.org/LDP/sag/html/index.html).

### Auditoría y Ciberseguridad:
14. **NIST SP 800-92:** [Guía para la gestión de logs en seguridad informática](https://csrc.nist.gov/publications/detail/sp/800-92/final).
15. **OWASP - Logging Cheat Sheet:** [Buenas prácticas de logging para seguridad](https://cheatsheetseries.owasp.org/cheatsheets/Logging_Vocabulary_Cheat_Sheet.html).
16. **CIS Benchmarks for Linux:** [Estándares de endurecimiento de sistemas](https://www.cisecurity.org/benchmarks/).

### Recursos para Estudiantes (SMR/ASIR/DAM):
17. **The Debian Administrator's Handbook:** [Gestión de paquetes y repositorios (Imprescindible)](https://debian-handbook.info/).
18. **Google Shell Style Guide:** [Estándares de programación profesional en Bash](https://google.github.io/styleguide/shellguide.html).
19. **Infrastructure as Code (IaC) Patterns:** [Principios de automatización modernos](https://www.hashicorp.com/resources/what-is-infrastructure-as-code).
20. **ShellCheck:** [Herramienta de análisis estático para scripts de Bash (Fundamental)](https://www.shellcheck.net/).
21. **Cybersecurity Standards (ISO/IEC 27001):** [Introducción a la gestión de seguridad de la información](https://www.iso.org/isoiec-27001-information-security.html).
22. **TryHackMe / HackTheBox:** [Plataformas para practicar administración de sistemas y seguridad](https://tryhackme.com/).

### Programación Robusta y Validación (Nuevo):
23. **Bash Pitfalls:** [Errores comunes y cómo evitarlos para scripts robustos](https://mywiki.wooledge.org/BashPitfalls).
24. **Pure Bash Bible:** [Colección de fragmentos de Bash puro para evitar dependencias externas](https://github.com/dylanaraps/pure-bash-bible).
25. **RFC 3986 - URI Generic Syntax:** [Estándar oficial sobre la codificación de caracteres en URLs](https://datatracker.ietf.org/doc/html/rfc3986).
26. **OWASP Input Validation:** [Guía para prevenir vulnerabilidades mediante la validación de entradas](https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html).

### Microinformática y Hardware (Nuevo):
27. **GNU Parted User's Manual:** [Guía avanzada sobre particionado de discos y tablas de particiones](https://www.gnu.org/software/parted/manual/parted.html).
28. **VBoxManage Reference:** [Manual de control de VirtualBox desde línea de comandos](https://www.virtualbox.org/manual/ch08.html).
29. **Linux Filesystem Hierarchy Standard (FHS):** [Entendiendo la estructura de directorios en Linux](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).
30. **PC Part Picker / TechPowerUp:** [Bases de datos de hardware para dimensionamiento de sistemas](https://www.techpowerup.com/).
