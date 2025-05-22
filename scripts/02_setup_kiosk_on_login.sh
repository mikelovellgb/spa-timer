#!/usr/bin/env bash
# setup-kiosk.sh — configure Chromium kiosk and hide mouse pointer on GUI login via .desktop autostart + DietPi unclutter hack
set -euo pipefail

# Determine deploy user & home directory
dep_user=""
if [ "$EUID" -eq 0 ]; then
  dep_user="${SUDO_USER:-pi}"
else
  dep_user="$(whoami)"
fi
user_home="$(eval echo "~${dep_user}")"

echo "Configuring kiosk autostart for user ${dep_user} (home: ${user_home})"

# 1) Ensure Chromium is installed
if ! command -v chromium-browser >/dev/null 2>&1; then
  echo "Installing Chromium..."
  sudo apt update
  sudo apt install -y chromium-browser
fi

# 2) Ensure unclutter is installed (to hide on-screen pointer)
if ! command -v unclutter >/dev/null 2>&1; then
  echo "Installing unclutter..."
  sudo apt update
  sudo apt install -y unclutter
fi

# 3) DietPi-specific hack: create /etc/chromium.d/dietpi-unclutter to auto-hide cursor
if command -v unclutter >/dev/null 2>&1; then
  echo "Applying DietPi unclutter hack..."
  sudo mkdir -p /etc/chromium.d
  echo "/usr/bin/unclutter -idle 0.1 &" | sudo tee /etc/chromium.d/dietpi-unclutter >/dev/null
fi

# 4) Create user-level autostart directory and .desktop entries
autostart_dir="${user_home}/.config/autostart"
mkdir -p "${autostart_dir}"

# Chromium kiosk entry
cat > "${autostart_dir}/chromium-kiosk.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Chromium Kiosk
Exec=chromium-browser --noerrdialogs --disable-infobars --kiosk http://localhost:3000
X-GNOME-Autostart-enabled=true
EOF

# Unclutter entry for fallback/hybrid hide
cat > "${autostart_dir}/unclutter.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Hide Mouse Pointer
Exec=unclutter -idle 0.1
X-GNOME-Autostart-enabled=true
EOF

# 5) Fix ownership
sudo chown -R "${dep_user}:${dep_user}" "${user_home}/.config"

echo "Kiosk setup complete. Reboot your Pi to apply changes (Chromium kiosk + hidden mouse cursor)."
