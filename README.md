# Creador de Máquinas Virtuales Marca Acme

Este script profesional automatiza la creación de infraestructuras virtualizadas para **VirtualBox**, **VMware** y **QEMU** utilizando el método de **Debootstrap** y **Chroot**.

## Características Destacadas

- **Personalización Masiva de Fondos:**
    - Introduce múltiples términos de búsqueda separados por **comas** (ej: `espacio,cyberpunk,pokemon`).
    - Descarga **10 imágenes de alta calidad por cada término**, creando una biblioteca estética rica dentro de tu VM.
- **Gestión de Software Inteligente:**
    - Soporte para paquetes **APT**, **Flatpak** y **Snap** (introducidos por comas).
    - Configuración automática de repositorios como **Flathub**.
- **Seguridad Host-Invitado:**
    - Aislamiento total de GRUB: Instalación exclusiva en el disco virtual.
    - Protección del Host: Desactivación de `os-prober` para evitar interferencias con tu sistema operativo real.
- **Flujo de Trabajo Robusto:**
    - Test de integridad de compresión (7z) con respaldo automático.
    - Limpieza automática de carpetas temporales y montajes.
    - Registro detallado en `vm_creator.log` y modo **Verbose** opcional.

## Requisitos

- **Host Linux** con privilegios de `sudo`.
- Conexión a Internet activa.

## Uso

```bash
sudo ./create_vm.sh
```

El asistente te guiará. Cuando se te pregunten los fondos de pantalla, puedes poner varios temas:
`Fondos de Wallhaven (ej: pokemon,digimon): neon,cars,forest`

## Documentación Educativa

Este proyecto es una herramienta de aprendizaje avanzada. Consulta la [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md) para explorar:
- Manipulación de matrices (`arrays`) y variables de entorno (`IFS`) en Bash.
- Interacción avanzada con APIs REST mediante comandos de terminal.
- Gestión de flujos de error (stdout/stderr) y códigos de salida de Linux.
- Bibliografía técnica recomendada.

## Registro y Auditoría

Si encuentras algún problema, revisa el archivo `vm_creator.log`. Ha sido diseñado para separar los mensajes de estado de los datos técnicos, facilitando la identificación de errores.
