# Troubleshooting

## `nvidia-smi` says it can't communicate with the driver, and `lsmod | grep nvidia` is empty

Check whether a driver module exists for the kernel you are running:

```bash
uname -r
modinfo nvidia | head -5
dpkg -l | grep linux-modules-nvidia
```

If `modinfo` says `Module nvidia not found`, the prebuilt NVIDIA module package for your
kernel is missing (this happens when the kernel updates before the module package does).

```bash
sudo apt update
apt-cache policy linux-modules-nvidia-<driver>-open-$(uname -r)
sudo apt install linux-modules-nvidia-<driver>-open-$(uname -r)
```

Replace `<driver>` with your installed series (for example `595`). Then reboot into the newest
kernel if the userspace libraries were upgraded at the same time.

## `nvidia-smi -L` prints "No devices found" right after installing the module

Userspace libraries and the kernel module were probably upgraded to different driver versions.
Reboot into the newest kernel so the module package and libraries match.

## After the toggle disables the GPU, `dmesg` shows `Attempting to remove device ... with non-zero usage count`

The GPU was disabled while something still held it (`nvidia-persistenced`, or GNOME using the
NVIDIA DRM device). The firmware flag is set, but the driver is still attached. Prefer disabling
the GPU right after boot, or when nothing is using it. Test suspend from a clean boot first.

## Windows keeps turning the GPU off

Armoury Crate in **Eco** mode disables the dGPU at every Windows boot. Set Armoury Crate to
**Standard** in Windows. The GPU Toggle shutdown hook always hands over an enabled GPU, but
Armoury Crate can still disable it again if it is saved in Eco mode.

## The wake fix had no effect

* `grep LID0 /proc/acpi/wakeup` must show `*enabled` after reboot.
* If Secure Boot is on, kernel lockdown may ignore the ACPI override: `sudo dmesg | grep -i lockdown`.
* Check the override is in GRUB: `grep acpi_override /boot/grub/grub.cfg`.
