# Technical Documentation: Infrastructure Automation (Marca Acme)

This documentation is designed to serve as an advanced guide for IT students, Windows migrants and creative professionals who want to optimize their workflow in Linux.

## 1. Architecture and Robustness (v1.7.1)

The `create_vm.sh` script implements a layered build logic, designed to be resilient to changes in host and guest distributions.

*   **Anti-Blocking Services System (`policy-rc.d`):**
    1.  **The Problem:** When installing packages like `ModemManager` or database servers within a `chroot` environment, the system attempts to start services through `systemd` or `dbus`. Since the `chroot` environment does not have an active init system, the installation process indefinitely blocks waiting for a success signal that never arrives.
    2.  **The Solution:** A policy control mechanism (`/usr/sbin/policy-rc.d`) has been implemented.
        -   At the start of the `chroot`, this script is created returning exit code `101`.
        -   This code tells Debian/Ubuntu post-installation scripts **not to attempt to start the service**.
        -   At the end of the construction, the file is removed to allow normal system operation once the VM starts.

*   **Host Dependency Management:**
    Triple verification logic is used to ensure critical tools like `qemu-img` or `debootstrap` are present, including fallback systems for virtual packages in modern Ubuntu versions.

*   **Smart Snap System:**
    Implements a "delayed post-installation" service (`acme-first-boot.service`) that solves the impossibility of installing Snaps inside a `chroot` without mounted `squashfs` file systems.

*   **Mirror Caching:**
    Caches the fastest mirror found during the first run to speed up subsequent executions, reducing deployment time.

*   **Parallel Mirror Testing:**
    Implements parallel network testing to find the fastest mirror from a list of candidates, significantly reducing mirror selection time.

## 2. Guidance Profile

### A. IT Students (SMR, ASIR, DAW/DAM, Cybersecurity)
*   **Microinformatics:** The script is a living laboratory on the Linux directory hierarchy (FHS) and device loop management.
*   **Systems:** The network block demonstrates the use of `Netplan` and the transition from inherited configurations of `/etc/network/interfaces`.
*   **Cybersecurity:** Allows generating "Infrastructure as Code" (IaC) environments for Red Team / Blue Team labs.

### B. Migrants from Windows (Survival and Efficiency)
*   **Sustainable Hardware:** Linux allows old computers with older processors or without TPM chips to run fluently, something Windows 11 prohibits.
* **Software Equivalences:** Flatpak is recommended to obtain always-updated versions of browsers and office tools without depending on the base system.

### C. Creatives: Design, Video and Streaming (Resource Economy)
*   **Low Latency Kernel:** The script facilitates the installation of the **Ubuntu Studio** flavor, optimizing the kernel to avoid "jitter" or latency in audio recordings and live streamings.
* **Video Performance:** Without telemetry or heavy antivirus processes, Linux dedicates more CPU cycles to rendering in applications like **Blender** or **Kdenlive**.

## 3. Educational and Technical Resources

### Systems and Automation
1.  **The Debian Administrator's Handbook:** [Official administration guide](https://debian-handbook.info/browse/stable/).
2.  **Vagrant Internals:** [Box architecture documentation](https://www.vagrantup.com/docs/providers).
3.  **Netplan Reference:** [Modern network configuration in Ubuntu](https://netplan.io/reference/).
4.  **Filesystem Hierarchy Standard:** [FHS 3.0 Specification](https://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html).

### Multimedia and Production
5.  **Ubuntu Studio Audio Guide:** [Technical wiki about audio in Linux](https://ubuntustudio.org/manual/audio/).
6.  **Krita Documentation:** [Manual for digital artists](https://docs.krita.org/es/).
7.  **PipeWire Project:** [The future of audio and video in Linux](https://pipewire.org/).
8.  **OBS Studio Studio Mode:** [Documentation for streamers](https://obsproject.com/wiki/OBS-Studio-Overview).

### Initiation and Transition
9.  **Linux Journey:** [Complete interactive tutorial](https://linuxjourney.com/).
10. **AlternativeTo Linux:** [Program equivalence finder](https://alternativeto.net/platform/linux/).
11. **DistroWatch:** [Linux distributions database](https://distrowatch.com/).
12. **Arch Wiki:** Universal technical reference (even for Debian/Ubuntu users). [wiki.archlinux.org](https://wiki.archlinux.org/).

## 4. Change Log Highlights (v1.7.1)

*   **Mirror Caching System:** Added cache mechanism to store the fastest mirror found, avoiding redundant network testing.
* **Parallel Mirror Testing:** Optimized mirror selection by limiting tests to the top 10 candidates, reducing selection time by approximately 70%.
*   **Wallpaper Download Improvements:** Added retry logic and image format filtering to prevent failed downloads and ensure only valid image files are saved.
* **Dependency Validation:** Added input validation for RAM, CPU cores and disk size parameters at argument parsing time.
* **GRUB Installation Fix:** Fixed variable expansion issue where `$1` inside the chroot script was not correctly passing the device parameter.
* **Flatpak Improvement:** Improved Flatpak ID detection logic to properly distinguish between full IDs and package names.
* **Error Handling:** Enhanced error handling in wallpaper downloads, Flatpak installation and mirror selection.

## 5. Bibliography and Educational Resources

(Same as Spanish version - see README.md for full list)