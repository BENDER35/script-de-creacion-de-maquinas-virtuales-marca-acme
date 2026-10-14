# VM-Acme: Virtual Machine Generator for FP and University

![Version](https://img.shields.io/badge/version-1.7.1-blue.svg)
![Field](https://img.shields.io/badge/purpose-Educational/Systems/Creative-green.svg)

This tool allows creating customized (Debian/Ubuntu) virtual machine images fully automated. It is a pedagogical and professional resource designed to democratize access to technology, ideal for those seeking a powerful and free alternative to proprietary systems.

## 🎯 User Profiles

*   **IT Students, Programming, Cybersecurity and Microinformatics:**
    *   **Initiation (SMR/ASIR):** Learn how an operating system is built from its foundations. The script is an open lesson on partitioning, mounts and package management.
    *   **Network Labs:** Generates complete infrastructures in seconds to practice routing, firewalling or pentesting.
    *   **Automation (DAW/DAM):** Study the source code to master Bash and infrastructure as code (IaC).
*   **Windows Migrants (Home and Office):**
    *   **Safe Transition:** Don't break your main computer. Create virtual machines to learn Linux, its terminal and its freedom philosophy without risks.
    *   **Total Privacy:** Forget data tracking and forced updates that slow down your work.
*   **Creatives (Design, Illustration, Video and Streaming):**
    *   **Economic Alternative:** If you can't afford monthly Adobe subscriptions or your hardware doesn't support Windows 11, Linux is your salvation.
    *   **Old Hardware:** Give a second life to that equipment Windows considers "obsolete". Linux flies where other systems crawl.
    *   **Professional Software:** Use **Krita** for illustration, **Blender** for 3D, **Kdenlive** for video editing and **OBS Studio** for your broadcasts.

## 🚀 Key Features (v1.7.1)

*   **Anti-Blocking `policy-rc.d` System:** Guarantees that installation never stops due to rebel services (like `ModemManager`). **Absolute stability in Hyper-V and virtualized environments**. Features **color-coded logging** for better visual feedback during execution (Red for errors, Yellow for warnings, Green for info, Cyan for debug).
*   **Smart Dependency Management:** Detection of virtual packages and fallback providers (e.g.: `qemu-user-binfmt`).
*   **Professional Multi-Format:** Support for **VirtualBox**, **VMware**, **QEMU**, **RAW**, **RootFS**, **Vagrant** and **Hyper-V**.
*   **QEMU Support:** Converts RAW images to QCOW2 format for efficient virtual machine storage.
*   **Vagrant Support:** Creates Vagrant boxes with metadata.json and Vagrantfile for libvirt/KVM provider.

*   **Intelligent Snap Installation:**
*   **Intelligent Snap Installation:** Automatic detection of `--classic` requirements for creative software.
*   **Mirror Caching:** Caches the fastest mirror found to speed up subsequent runs.
*   **Parallel Mirror Testing:** Finds the fastest mirror through parallel network testing, reducing selection time by approximately 70%.
*   **Legacy Ubuntu Support:** Permite crear máquinas virtuales de Ubuntu incluso en versiones que ya no tienen soporte oficial. El script permite especificar un codename personalizado y emite una advertencia si la versión no tiene soporte oficial.
*   **Kali Linux Support:** The script now supports creating virtual machines with Kali Linux, the leading penetration testing distribution. Includes support for Kali Rolling (default) and various desktop environments (Kali GNOME, Kali KDE, Kali XFCE, Kali LXQt, Kali MATE).

## 📘 Beginner and Professional Guide

### 🎓 IT Students
- **Cybersecurity:** Create "victim" and "attacker" machines with isolated network configurations.
- **Microinformatics:** Observe how `debootstrap` installs only what is necessary. The base for understanding "informatic minimalism".

### 🪟 If you come from Windows
- **Software Equivalent:** Use **LibreOffice** for Office, **GIMP** for Photoshop and **Inkscape** for Illustrator. Most are free and open source.
- **Safe Installation:** Here you don't download strange ".exe" files. Everything comes from community-verified repositories.

### 🎨 Creatives and Streamers
- **Illustration:** Connect your graphics tablet (Wacom, Huion, XP-Pen) and open **Krita**. Pressure and color management is amazing.
- **Video Editing:** **Kdenlive** allows 4K editing with proxies, ideal if your equipment has few resources.
- **Streaming:** **OBS Studio** on Linux consumes less CPU, allowing your games or design applications to run better while you broadcast.

## 🛠️ Quick Start Guide

```bash
# Example: Create a machine for a networking student
sudo ./create_vm.sh --name lab_redes --os debian --ram 1024 --desktop none --apt nmap,tcpdump

# Example: Create a station for a digital illustrator
sudo ./create_vm.sh --name estudio_arte --os ubuntu --desktop xfce --apt krita,gimp,inkscape
```

## 📚 Bibliography and Learning Resources

### 🛠️ Technology and Systems
1.  **Debian Administrator's Handbook:** The definitive guide to understanding the system. [debian-handbook.info](https://debian-handbook.info/browse/stable/).
2.  **Linux Journey:** A structured course from the most basic to server administration. [linuxjourney.com](https://linuxjourney.com/).
3.  **Vagrant Docs:** Learn to automate your test laboratories. [vagrantup.com/docs](https://www.vagrantup.com/docs).
4.  **QEMU Documentation:** Understand how hardware emulation works. [qemu.org/docs](https://qemu.org/docs/master/).

### 🎨 Multimedia Creation and Design
5.  **Krita Manual:** Professional manual for digital artists. [docs.krita.org](https://docs.krita.org/).
6.  **Ubuntu Studio Manual:** Guide to setting up a high-level multimedia production system. [ubuntustudio.org/manual/](https://ubuntustudio.org/manual/).
7.  **Blender Fundamentals:** Learn the industry standard for 3D. [docs.blender.org](https://docs.blender.org/manual/es/latest/).
8.  **Kdenlive User Manual:** Professional video editing step by step. [docs.kdenlive.org](https://docs.kdenlive.org/).

### 🐧 Transition and Digital Culture
9.  **AlternativeTo Linux:** Find the best free alternatives to your Windows programs. [alternativeto.net](https://alternativeto.net/platform/linux/).
10. **It's FOSS:** The best blog for beginners who want practical advice. [itsfoss.com](https://itsfoss.com/).
11. **DistroSea:** Try Linux in your browser without installing anything. [distrosea.com](https://distrosea.com/).
12. **Free Software Foundation (FSF):** Learn about the ethical importance of free software. [fsf.org](https://www.fsf.org/).

---

*This project is a digital resistance tool, designed so that no one falls behind for economic reasons or lack of access to expensive hardware.*