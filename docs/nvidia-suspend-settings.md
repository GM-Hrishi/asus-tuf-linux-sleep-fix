# NVIDIA suspend/wake settings that worked on this laptop

These are the settings in effect when suspend and wake worked with the RTX 4060 **on**
(Ubuntu, Wayland, NVIDIA open driver 595 series). They were applied together, so this
repo does not claim that every single one is individually required.

| Setting | Value | Where |
|---|---|---|
| Sleep mode | `mem_sleep_default=s2idle` | `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub` |
| Keep VRAM across sleep | `nvidia.NVreg_PreserveVideoMemoryAllocations=1` | GRUB cmdline and `/etc/modprobe.d/` |
| VRAM dump location | `NVreg_TemporaryFilePath=/var/tmp` | `/etc/modprobe.d/nvidia-graphics-drivers-kms.conf` |
| S0ix power management | `NVreg_EnableS0ixPowerManagement=1` | `/etc/modprobe.d/nvidia-graphics-drivers-kms.conf` |
| NVIDIA sleep services | enabled | `sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service` |
| Sleep hook script | present | `/lib/systemd/system-sleep/nvidia` |

Check what the loaded driver is actually using (with the GPU on):

```bash
grep -E "PreserveVideoMemory|TemporaryFilePath|S0ix|DynamicPower" /proc/driver/nvidia/params
```

Check the sleep mode:

```bash
cat /sys/power/mem_sleep      # expect: [s2idle] deep
```

Notes from debugging:

* Disabling `nvidia-suspend.service` while `PreserveVideoMemoryAllocations=1` is set makes the
  driver abort suspend with `nv_pmops_suspend ... returns -5`. Either keep the services enabled
  (recommended) or turn both off together.
* A suspend that ends in the log at `PM: suspend entry (s2idle)` with no error and never wakes is
  the signature of the missing `LID0 _PRW` bug fixed by this repo, not an NVIDIA problem.
