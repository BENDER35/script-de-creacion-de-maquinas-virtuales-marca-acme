# Creador de Máquinas Virtuales Marca Acme

Herramienta educativa para la automatización de despliegues Linux mediante `debootstrap` y `chroot`. Ideal para estudiantes de ciclos formativos de Grado Medio (SMR), Superior (ASIR/DAM/DAW) o autodidactas.

## 🚀 Inicio Rápido

1. **Clonar y dar permisos:**
   ```bash
   chmod +x create_vm.sh
   ```

2. **Ejecutar con ayuda para ver opciones:**
   ```bash
   sudo ./create_vm.sh --help
   ```

3. **Ejemplo de creación robusta (Debian Lab - Sistemas/Ciberseguridad):**
   ```bash
   sudo ./create_vm.sh --name "debian_pentest" --os debian --hyp vbox --desktop xfce --ram 4096
   ```

## 📚 Lo que aprenderás usando este script

Este proyecto es un laboratorio de aprendizaje avanzado:

*   **Sistemas y Ciberseguridad:** Gestión de repositorios de seguridad, firma de paquetes mediante GPG (método `signed-by`), instalación de drivers privativos mediante DKMS y endurecimiento del proceso de despliegue.
*   **Programación:** Generación dinámica de scripts (Heredocs), inyección de variables desde el host y manejo avanzado de flujos de E/S.
*   **DevOps:** Automatización de infraestructuras críticas y trazabilidad mediante logs de auditoría.

## 📊 Logging y Auditoría

El script genera el archivo `creacion_maquina.log` con trazabilidad completa de cada fase. Para ver un resumen cronológico de la evolución del proyecto, consulta el archivo [HISTORIAL_CAMBIOS.md](HISTORIAL_CAMBIOS.md).

## 📖 Documentación Completa

Para una explicación detallada de cada módulo, el uso del repositorio **Debian Fast Track** para compatibilidad con VirtualBox, y una bibliografía técnica extensa, consulta el archivo [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md).

---
*Proyecto creado con fines educativos para potenciar el conocimiento en administración de sistemas y desarrollo de herramientas de automatización.*
