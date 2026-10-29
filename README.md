# ASUS TUF F15 Linux Suspend / Wake Fix (Ubuntu & Arch)

Are you experiencing an issue where your **ASUS TUF F15** (such as the FX507 / 13th Gen Intel series) goes to sleep in Linux (`s2idle` / Modern Standby), but **refuses to wake up** when you press the power button, use the keyboard, or open the lid—forcing a hard restart? 

This repository provides a permanent ACPI SSDT table override fix for the missing `_PRW` power resource on `LID0`.

## Symptoms
* Laptop suspends successfully, but the screen stays black and inputs do not wake it up.
* `grep LID0 /proc/acpi/wakeup` returns a blank output.
* System logs show `PM: suspend entry (s2idle)` but no wake events trigger.

## Keywords & Error Triggers
asus tuf f15 ubuntu suspend fix, asus tuf wont wake up from sleep linux, asus tuf modern standby wake bug, acpi wakeup lid0 s2idle, ubuntu 24.04 24.10 asus tuf sleep bug fix.
