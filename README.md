# VM-Acme: Generador de Laboratorios Virtuales

![Version](https://img.shields.io/badge/version-1.2.5-blue.svg)
![Field](https://img.shields.io/badge/fines-Educativos/Sistemas/Ciberseguridad-green.svg)

Esta herramienta permite crear imágenes de máquinas virtuales (Debian/Ubuntu) personalizadas de forma totalmente automatizada. Es ideal para estudiantes y profesionales de:
*   **Sistemas y Microinformática:** Entender el proceso de despliegue de SO desde cero (`debootstrap`).
*   **Ciberseguridad:** Crear sandboxes rápidos para análisis de malware o laboratorios de pentesting.
*   **Programación:** Configurar entornos de desarrollo limpios y replicables.

## 🚀 Características Principales
*   **Automático:** De la ISO al disco virtual sin intervención manual.
*   **Personalizable:** Selección de escritorio, software (APT, Flatpak, Snap) y wallpapers.
*   **Resiliente:** Mecanismos internos para reparar dependencias y configurar entornos chroot.
*   **Multi-Hypervisor:** Soporta VirtualBox, VMware y QEMU/KVM.

## 🛠️ Uso para Estudiantes
Para iniciar la construcción de tu laboratorio, ejecuta:
```bash
sudo ./create_vm.sh
```
El script te guiará mediante un asistente interactivo.

## 📚 Bibliografía y Recursos de Aprendizaje
Para profundizar en las tecnologías que utiliza este script, recomendamos:

### Sistemas Operativos y Despliegue
1.  **Debian Handbook:** La guía definitiva sobre la administración de Debian. [debian.org/doc/manuals/debian-handbook](https://www.debian.org/doc/manuals/debian-handbook/index.es.html)
2.  **Debootstrap Wiki:** Entender cómo se construye un sistema base. [wiki.debian.org/Debootstrap](https://wiki.debian.org/Debootstrap)

### Automatización y Scripting
3.  **Advanced Bash-Scripting Guide:** Para entender el uso de Heredocs y automatización de procesos. [tldp.org/LDP/abs/html/](https://tldp.org/LDP/abs/html/)
4.  **Chroot & Jail Environments:** Conceptos de aislamiento en Linux.

### Microinformática y Virtualización
5.  **VirtualBox SDK & VBoxManage:** Documentación oficial para automatizar VMs.
6.  **QEMU Documentation:** Manejo de formatos de disco (RAW, QCOW2, VMDK).

## 🛡️ Notas de Ciberseguridad
Este script genera usuarios con permisos `sudo` sin contraseña por defecto para facilitar el aprendizaje. **No utilices estas imágenes en entornos de producción expuestos a internet sin endurecer primero las políticas de seguridad.**

---
*Desarrollado como herramienta de apoyo para el aprendizaje de administración de sistemas y redes.*
