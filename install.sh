#!/usr/bin/env bash
# ASUS TUF F15 s2idle wake fix:
# injects the missing _PRW for LID0 through an ACPI SSDT table override.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user (not with sudo). It asks for sudo when needed."
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

if grep -q '^LID0' /proc/acpi/wakeup 2>/dev/null; then
    echo "LID0 is already listed in /proc/acpi/wakeup: the fix is probably not needed (or already applied)."
    read -r -p "Continue anyway? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || exit 0
fi

if command -v mokutil >/dev/null 2>&1 && mokutil --sb-state 2>/dev/null | grep -qi 'enabled'; then
    echo "WARNING: Secure Boot is enabled. Kernel lockdown may ignore ACPI table overrides."
    echo "         If the fix has no effect after reboot, check: sudo dmesg | grep -i lockdown"
fi

echo "[+] Installing acpica-tools and cpio..."
sudo apt-get update
sudo apt-get install -y acpica-tools cpio

echo "[+] Checking that your BIOS has the LID0 device this patch targets..."
# shellcheck disable=SC2024  # sudo only needs to read the root-only table; the output file is ours
sudo cat /sys/firmware/acpi/tables/DSDT > "$WORK/dsdt.dat"
(cd "$WORK" && iasl -d dsdt.dat >/dev/null 2>&1 || true)
if ! grep -q 'Device (LID0)' "$WORK/dsdt.dsl" 2>/dev/null; then
    echo "ERROR: no 'Device (LID0)' found in your DSDT. This fix is not for your laptop. Nothing was changed."
    exit 1
fi

echo "[+] Compiling the ACPI SSDT override..."
cp "$DIR/ssdt-lidwake.asl" "$WORK/"
(cd "$WORK" && iasl -tc ssdt-lidwake.asl)

echo "[+] Packaging into an early initrd (acpi_override.cpio)..."
mkdir -p "$WORK/cpio/kernel/firmware/acpi"
cp "$WORK/ssdt-lidwake.aml" "$WORK/cpio/kernel/firmware/acpi/"
(cd "$WORK/cpio" && find kernel | cpio -H newc --create --owner=0:0 > "$WORK/acpi_override.cpio")
sudo install -m 644 "$WORK/acpi_override.cpio" /boot/acpi_override.cpio

echo "[+] Configuring GRUB..."
[ -f /etc/default/grub.bak-sleepfix ] || sudo cp -a /etc/default/grub /etc/default/grub.bak-sleepfix
if grep -q '^GRUB_EARLY_INITRD_LINUX_CUSTOM=' /etc/default/grub; then
    if grep -q '^GRUB_EARLY_INITRD_LINUX_CUSTOM=.*acpi_override.cpio' /etc/default/grub; then
        echo "    GRUB_EARLY_INITRD_LINUX_CUSTOM already points at acpi_override.cpio."
    else
        echo "ERROR: /etc/default/grub already sets GRUB_EARLY_INITRD_LINUX_CUSTOM to something else."
        echo "       Add acpi_override.cpio to that line yourself, then run: sudo update-grub"
        exit 1
    fi
else
    echo 'GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override.cpio"' | sudo tee -a /etc/default/grub >/dev/null
fi
sudo update-grub

echo
echo "[+] Done. Reboot, then verify with:  grep LID0 /proc/acpi/wakeup"
echo "    Expected: LID0   S0   *enabled   platform:PNP0C0D:01"
