#!/bin/bash
set -e

echo "[+] Installing acpica-tools and cpio..."
sudo apt update && sudo apt install -y acpica-tools cpio

echo "[+] Compiling ACPI SSDT table override..."
iasl -tc ssdt-lidwake.asl

echo "[+] Packaging into early initrd (acpi_override.cpio)..."
mkdir -p cpio/kernel/firmware/acpi
cp ssdt-lidwake.aml cpio/kernel/firmware/acpi/
(cd cpio && find kernel | cpio -H newc --create --owner=0:0 > ../acpi_override.cpio)
sudo cp acpi_override.cpio /boot/

echo "[+] Configuring GRUB..."
if ! grep -q "GRUB_EARLY_INITRD_LINUX_CUSTOM" /etc/default/grub; then
    echo 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override.cpio"' | sudo tee -a /etc/default/grub
fi

sudo update-grub
echo "[+] Done! Please reboot your system and verify with: grep LID0 /proc/acpi/wakeup"
