ASUS TUF F15 Linux Suspend & Wake Fix (s2idle)

Are you using an ASUS TUF F15 (such as the FX507 series with 13th Gen Intel processors) running Ubuntu or Linux, and noticing that your laptop refuses to wake up after suspending?

Even though the laptop goes to sleep normally (lights fade, fans stop), pressing the power button, typing on the keyboard, or opening the lid does nothing, forcing you to hold down the power button to hard-restart every time. This repository provides a permanent fix.

🔍 Why Does This Happen?

Modern laptops use Modern Standby (s2idle), but due to an oversight in the ASUS BIOS ACPI tables, the motherboard manufacturer completely omitted the power resource (_PRW) for the active lid device (LID0). Because of this, Linux automatically disarms the wake interrupt (GPE 0x02), leaving your hardware deaf to wake signals.

This fix compiles a small 93-byte ACPI SSDT table override that injects the missing _PRW definition, restoring full wake functionality to your power button, keyboard, and lid.

🛠️ How to Use This Fix (For Beginners)

If you are new to Linux, follow these simple steps to apply the fix automatically using the provided installer script.

Step 1: Open your Terminal

Open your terminal application (you can press Ctrl + Alt + T on Ubuntu).

Step 2: Download or Clone the Repository

Run the following command to download or clone this repository to your home folder:

cd ~ && git clone https://github.com/GM-Hrishi/asus-tuf-linux-sleep-fix.git


Step 3: Enter the Folder

Move into the newly created folder by running:

cd asus-tuf-linux-sleep-fix


Step 4: Run the Installer Script

Execute the automated installation script by typing:

chmod +x install.sh && ./install.sh


(You will be prompted to enter your Ubuntu account password. The script will automatically install required compiler tools, compile the ACPI patch, pack it into an early initrd override, update GRUB, and configure everything for you).

Step 5: Reboot Your Laptop

Once the script finishes successfully, restart your system:

sudo reboot


✅ How to Verify It Worked

After your laptop reboots back into Ubuntu, open your terminal and run this verification command:

grep LID0 /proc/acpi/wakeup


If the fix was successful, it should output:

LID0      S0    *enabled   platform:PNP0C0D:01


(Notice the *enabled status instead of a blank output).

Now, try closing your lid or pressing the suspend button—your ASUS TUF F15 will wake up smoothly every single time!

⚙️ Manual Steps (What the script does under the hood)

If you prefer doing it manually:

Installs acpica-tools and cpio.

Compiles ssdt-lidwake.asl into ssdt-lidwake.aml using iasl.

Packages the binary into a custom early initrd image (acpi_override.cpio) placed inside /boot/.

Appends GRUB_EARLY_INITRD_LINUX_CUSTOM="acpi_override.cpio" to /etc/default/grub.

Updates GRUB (sudo update-grub).
