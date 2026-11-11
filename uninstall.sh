#!/usr/bin/env bash
# Removes the ACPI wake override installed by install.sh.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user (not with sudo)."
    exit 1
fi

sudo sed -i '/^GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override.cpio"$/d' /etc/default/grub
sudo rm -f /boot/acpi_override.cpio
sudo update-grub
echo "[+] Removed. Reboot to go back to the stock BIOS tables."
