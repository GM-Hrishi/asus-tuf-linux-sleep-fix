#!/usr/bin/env bash
# Installs the GPU Toggle app: confirm-before-flip dGPU switch for ASUS laptops.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user (not with sudo). It asks for sudo when needed."
    exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
A1=/sys/class/firmware-attributes/asus-armoury/attributes/dgpu_disable/current_value
A2=/sys/devices/platform/asus-nb-wmi/dgpu_disable

if [ ! -e "$A1" ] && [ ! -e "$A2" ]; then
    echo "ERROR: no ASUS dgpu_disable interface found on this kernel."
    echo "Looked for:"
    echo "  $A1"
    echo "  $A2"
    exit 1
fi

echo "[+] Installing dependencies (zenity, notifications, psmisc)..."
sudo apt-get install -y zenity libnotify-bin psmisc

echo "[+] Installing the root helper..."
sudo install -m 755 -o root -g root "$DIR/gpu-set" /usr/local/sbin/gpu-set

echo "[+] Allowing passwordless sudo for that helper only..."
TMP="$(mktemp)"
echo "$(id -un) ALL=(root) NOPASSWD: /usr/local/sbin/gpu-set" > "$TMP"
sudo visudo -cf "$TMP"
sudo install -m 440 -o root -g root "$TMP" /etc/sudoers.d/gpu-set
rm -f "$TMP"

echo "[+] Installing the toggle and app-grid launcher..."
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
install -m 755 "$DIR/gpu-toggle" "$HOME/.local/bin/gpu-toggle"
cat > "$HOME/.local/share/applications/gpu-toggle.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=GPU Toggle
Comment=Enable or disable the dGPU (asks before flipping)
Exec=$HOME/.local/bin/gpu-toggle
Icon=video-display
Terminal=false
Categories=Utility;
DESKTOP

echo "[+] Installing the shutdown hook (re-enables the dGPU on shutdown/reboot)..."
sudo install -m 644 "$DIR/gpu-restore.service" /etc/systemd/system/gpu-restore.service
sudo systemctl daemon-reload
sudo systemctl enable --now gpu-restore.service

echo
echo "[+] Done. Open 'Show Apps' -> GPU Toggle (right-click -> Add to Favorites to pin it)."
