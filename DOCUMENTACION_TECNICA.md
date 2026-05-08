# Documentación Técnica: Automatización de Infraestructura (Marca Acme)

Esta documentación está diseñada para estudiantes de **Sistemas** y **Programación** que deseen entender cómo orquestar la creación de entornos Linux de forma profesional.

## 1. Arquitectura del Script (Perspectiva de Programación)

El script `create_vm.sh` utiliza un enfoque modular y robusto basado en Bash:

*   **Gestión de Errores (Error Handling):** Se utiliza `set -e` y `set -o pipefail` para detener la ejecución ante cualquier fallo, y un `trap` de limpieza (`cleanup`) para liberar recursos (montajes, dispositivos loop).
*   **Inyección de Variables y Generación Dinámica:** Una técnica avanzada utilizada es la generación del script de provisión (`setup.sh`) mediante *Heredocs*. Para evitar errores de expansión de variables dentro del entorno `chroot`, la lógica de decisión (como qué paquetes instalar) se ejecuta en el **Host**. Esto garantiza que el script generado sea estático y predecible, una práctica recomendada en el desarrollo de herramientas de automatización.
*   **Logging Avanzado:** Sistema de logs con niveles (`INFO`, `DEBUG`, etc.) y captura de flujos de salida de subprocesos, esencial para la trazabilidad en sistemas complejos.

## 2. Administración de Sistemas (Infraestructura como Código)

*   **Gestión de Repositorios y Drivers:** Para sistemas como Debian, es crucial configurar no solo los repositorios `main`, sino también `contrib`, `non-free` y los repositorios de **seguridad**.
*   **Debian Fast Track:** En versiones recientes de Debian (como 12 Bookworm o 13 Trixie), las herramientas de invitado de VirtualBox pueden no estar presentes en los repositorios estándar debido a ciclos de lanzamiento. El script integra automáticamente el repositorio **Fast Track**, un proyecto oficial de Debian que proporciona paquetes actualizados (backports) de software como VirtualBox para garantizar la compatibilidad de drivers.
*   **Repositorio Backports:** Requisito indispensable para Fast Track. El script habilita automáticamente los backports oficiales de Debian para asegurar que las dependencias de bajo nivel estén satisfechas.
*   **Compilación de Módulos (DKMS):** El script automatiza la instalación de `linux-headers`, `build-essential` y `dkms` cuando se detecta VirtualBox. Esto es vital para que los drivers del invitado se compilen correctamente contra el kernel instalado en el entorno `chroot`.

## 3. Seguridad y Confianza: Gestión de Llaves GPG

En la administración de sistemas Linux, la autenticidad de los paquetes se garantiza mediante criptografía de clave pública (GPG). Cuando añadimos un repositorio externo como **Fast Track**, debemos "decirle" a APT que confíe en él.

### Métodos para agregar llaves GPG (Educativo):

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

## 4. debootstrap y Repositorios con Firma

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

## 6. Registro de Cambios (Changelog Educativo)

*   **v1.3 - Refuerzo de Seguridad GPG:** Implementación del método `signed-by` para el repositorio Fast Track. Se añadió soporte para `gnupg` en el entorno chroot para permitir la gestión manual de llaves.
*   **v1.2 - Integración Fast Track:** Solución para la instalación de VirtualBox Guest Tools en Debian mediante el repositorio `fasttrack.debian.net`.
*   **v1.1 - Fix Drivers Debian:** Inclusión de repositorios `contrib` y `non-free`.
*   **v1.0 - Logging:** Sistema de logs detallados.

## 7. Bibliografía y Recursos Educativos Ampliados

### Documentación Oficial y Técnica:
1.  **Debian Fast Track Project:** [Paquetes actualizados para Debian Stable](https://fasttrack.debian.net/).
2.  **Debian Wiki - VirtualBox Guest Additions:** [Guía oficial de instalación](https://wiki.debian.org/VirtualBox/GuestAdditions).
3.  **Debian debootstrap Wiki:** [Creación de sistemas base](https://wiki.debian.org/Debootstrap).
4.  **Apt-Key Deprecation:** [Explicación sobre el fin de apt-key y el uso de signed-by](https://wiki.debian.org/DebianRepository/UseThirdParty).
5.  **GNU Privacy Guard (GnuPG):** [Manual oficial de GPG](https://gnupg.org/documentation/manuals/gnupg/).
6.  **DKMS Project Documentation:** [Dynamic Kernel Module Support](https://github.com/dell/dkms).
7.  **Linux Kernel Headers:** [Por qué son necesarios para compilar módulos](https://kernelnewbies.org/KernelHeaders).
8.  **Bash Manual - Here Documents:** [Referencia de redirección avanzada](https://www.gnu.org/software/bash/manual/html_node/Redirections.html#Here-Documents).
9.  **QEMU Documentation:** [Formatos de imagen de disco](https://www.qemu.org/docs/master/system/images.html).

### Recursos para Estudiantes (SMR/ASIR/DAM):
10. **The Debian Administrator's Handbook:** [Gestión de paquetes y repositorios (Imprescindible)](https://debian-handbook.info/).
11. **Google Shell Style Guide:** [Estándares de programación profesional en Bash](https://google.github.io/styleguide/shellguide.html).
12. **Infrastructure as Code (IaC) Patterns:** [Principios de automatización modernos](https://www.hashicorp.com/resources/what-is-infrastructure-as-code).
13. **Ciberseguridad en el despliegue:** [Guía de endurecimiento de imágenes Linux (CIS Benchmarks)](https://www.cisecurity.org/benchmark/debian_linux).
14. **Formación Profesional (TodoFP):** [Currículo de Sistemas Microinformáticos y Redes](https://www.todofp.es/).
de Sistemas Microinformáticos y Redes](https://www.todofp.es/).
17. **TryHackMe / HackTheBox:** [Plataformas para practicar administración de sistemas y seguridad](https://tryhackme.com/).
