# Creador de Máquinas Virtuales Marca Acme

Herramienta educativa para la automatización de despliegues Linux mediante `debootstrap` y `chroot`. Ideal para estudiantes de ciclos formativos de Grado Medio (SMR), Superior (ASIR/DAM/DAW) o autodidactas en los ámbitos de **Sistemas**, **Ciberseguridad** y **Programación**.

## 🚀 Inicio Rápido

1. **Clonar y dar permisos:**
   ```bash
   chmod +x create_vm.sh
   ```

2. **Ejecutar con ayuda para ver opciones:**
   ```bash
   sudo ./create_vm.sh --help
   ```

3. **Ejemplo de creación robusta (Laboratorio de Sistemas/Microinformática):**
   ```bash
   sudo ./create_vm.sh --name "aula_virtual" --os ubuntu --desktop edubuntu --ram 4096 --disk 100G --cpucores 4
   ```

## 📚 Lo que aprenderás usando este script

Este proyecto es un laboratorio de aprendizaje avanzado:

*   **Sistemas y Microinformática:** Configuración de hardware virtual (CPU, RAM, Disco), particionado de discos, sistemas de archivos (EXT4), montajes de dispositivos loop, y administración de recursos.
*   **Sabores de Linux:** Entenderás la diferencia entre las versiones estándar y los "sabores" educativos como **Edubuntu**, diseñados para fines pedagógicos específicos.
*   **Gestión de Software Moderno:** Aprenderás a integrar y solucionar problemas de dependencias en gestores de paquetes de nueva generación como **Flatpak** (aislamiento/sandboxing), **Snap** (servicios) y **Extrepo** (repositorios externos curados).
*   **Ciberseguridad:** Gestión de repositorios de seguridad, firma de paquetes mediante GPG (método `signed-by`), gestión de identidades y privilegios (`sudo`), y auditoría mediante logs detallados.
*   **Programación:** Automatización avanzada en Bash, generación dinámica de scripts (Heredocs), manejo de flujos de E/S (redirecciones de descriptores) y control de errores mediante señales (`traps`).

## 📊 Gestión de Identidad y Auditoría

El script integra conceptos fundamentales de seguridad:
*   **Credenciales Flexibles:** Puedes optar por un usuario personalizado para aprender sobre permisos `sudo`, o utilizar el modo de administración clásico `root/toor` común en laboratorios de seguridad.
*   **Logging de Transparencia Total:** Cada ejecución genera un informe detallado llamado `informe_imp_maqvirt(DD-MM-AAAA).log`. Esto permite a los estudiantes auditar cada paso del proceso de construcción, una habilidad esencial para el cumplimiento normativo y la respuesta ante incidentes.

## 📖 Documentación Completa y Formación

Este proyecto no es solo un script, es un recurso didáctico integral que incluye:
1.  **Sistemas**: Explicación de la arquitectura de despliegue y drivers mediante DKMS.
2.  **Ciberseguridad**: Guía sobre la gestión de llaves GPG y seguridad en el aprovisionamiento.
3.  **Programación**: Mejores prácticas en el desarrollo de herramientas de infraestructura como código (IaC).

Para una explicación técnica profunda, el uso del repositorio **Debian Fast Track** y una bibliografía educativa exhaustiva con más de 20 recursos profesionales, consulta el archivo [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md).

---
*Proyecto creado con fines educativos para potenciar el conocimiento en administración de sistemas, ciberseguridad y desarrollo de herramientas de automatización.*
