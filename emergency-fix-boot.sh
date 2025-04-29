#!/bin/bash

# emergency-fix-boot.sh

LOG_FILE="/var/log/emergency-fix-boot.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========== Emergency Boot Recovery Started at $(date) =========="

# 1. Restart the Display Manager (like gdm, lightdm, sddm)
echo "[INFO] Attempting to restart the display manager..."
for service in gdm3 gdm lightdm sddm; do
  if systemctl list-units --type=service | grep -q "$service"; then
    echo "[INFO] Found display manager: $service. Restarting..."
    systemctl restart "$service"
    sleep 5
    systemctl status "$service"
    break
  fi
done

# 2. Check if GUI is back
echo "[INFO] Checking if GUI is back..."
sleep 10
GUI_UP=$(ps aux | grep -E 'Xorg|Xwayland' | grep -v grep)

if [[ -n "$GUI_UP" ]]; then
  echo "[SUCCESS] GUI is running properly."
else
  echo "[WARN] GUI is not running. Falling back to CLI-only mode."

  # 3. Disable graphical boot temporarily
  echo "[INFO] Setting system to boot into multi-user (CLI) mode..."
  systemctl set-default multi-user.target
  systemctl isolate multi-user.target
  echo "[SUCCESS] Switched to CLI mode. GUI disabled."
fi

# 4. Optional: Log any recent boot errors
echo "[INFO] Capturing recent boot errors from journalctl..."
journalctl -p 3 -xb > /var/log/recent-boot-errors.log

# 5. Optional: Clean up broken Xorg sessions
rm -f /tmp/.X*-lock

echo "[INFO] Emergency recovery script completed."
echo "================================================================="

exit 0
# End of emergency-fix-boot.sh