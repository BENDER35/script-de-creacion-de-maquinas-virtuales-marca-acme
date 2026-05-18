# Historial de Cambios - Creador de Máquinas Virtuales Marca Acme

Este documento detalla la evolución del script `create_vm.sh` y las tareas realizadas en el proyecto.

## [1.7.0] - 2026-05-18
### Añadido
- **Sistema Anti-Bloqueo de Servicios (Propuesta 1)**: Implementación de `policy-rc.d` para garantizar la estabilidad absoluta durante la fase de construcción (`chroot`).
  - **Prevención de Cuelgues**: Evita que servicios como `ModemManager`, `MySQL` o `Apache` intenten arrancar dentro del entorno enjaulado, lo que causaba bloqueos infinitos en Hyper-V y otros entornos.
  - **Aislamiento de Instalación**: Asegura que el proceso de `apt-get install` se centre únicamente en desempaquetar y configurar archivos, delegando el arranque de servicios al primer inicio real de la VM.
### Modificado
- **Documentación Multidisciplinar (v2)**: Renovación total del README y la Documentación Técnica enfocada en la inclusión socioprofesional.
  - **Iniciación Técnica**: Guías específicas para estudiantes de Sistemas, Programación, Ciberseguridad y Microinformática (SMR/ASIR/DAM/DAW).
  - **Resistencia Creativa**: Sección dedicada a ilustradores, diseñadores y editores de vídeo que migran a Linux por ahorro de costes y hardware antiguo.
  - **Puente Windows-Linux**: Manual de aterrizaje suave para usuarios que abandonan ecosistemas propietarios.
  - **Bibliografía Académica y Profesional**: Inclusión de fuentes de consulta técnica y manuales de software creativo (Krita, Blender, OBS) en todos los documentos.

## [1.6.1] - 2026-05-17
### Corregido
- **Fallo de Dependencias (Virtual Packages)**: Se ha solucionado el error crítico que impedía la instalación de `qemu-user-static` en distribuciones modernas (como Ubuntu 26.04 "Resolute").
  - **Lógica de Fallback**: El script ahora detecta si `qemu-user-static` es un paquete virtual e intenta automáticamente la instalación de sus proveedores (`qemu-user-binfmt` o `qemu-user-binfmt-hwe`).
  - **Detección por Binarios**: Se ha mejorado la verificación de dependencias para comprobar la existencia real de los binarios en `/usr/bin/` antes de intentar una instalación redundante.

... rest of history remains the same ...
