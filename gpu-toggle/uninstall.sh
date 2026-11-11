#!/usr/bin/env bash
# Removes everything install.sh added.
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as your normal user (not with sudo)."
    exit 1
fi

sudo systemctl disable --now gpu-restore.service 2>/dev/null || true
sudo rm -f /etc/systemd/system/gpu-restore.service /etc/sudoers.d/gpu-set /usr/local/sbin/gpu-set
sudo systemctl daemon-reload
rm -f "$HOME/.local/bin/gpu-toggle" "$HOME/.local/share/applications/gpu-toggle.desktop"
echo "[+] GPU Toggle removed."
