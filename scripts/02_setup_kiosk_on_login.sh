#!/usr/bin/env bash
# 02_setup_kiosk_on_login.sh
#
# Sets up a kiosk environment for the Spa Timer web app.
# - Installs Chromium browser and unclutter (if not present)
# - Applies DietPi-specific hack for cursor hiding (if needed)
# - Creates autostart entries for Chromium in kiosk mode and unclutter
# - Ensures correct ownership of config files
#
# Usage: Run as the deploy user or with sudo. Designed for Raspberry Pi/Debian systems with a desktop environment.
#
# This script enables automatic launch of the timer app in fullscreen kiosk mode on login.

set -euo pipefail

# 0) (Optional) Enable Wayland if on Raspberry Pi OS (for kiosk stability)
echo "Enabling Wayland (raspi-config nonint do_wayland W1)..."
sudo raspi-config nonint do_wayland W1  # Enable Wayland for kiosk mode (if supported)

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

echo "Kiosk setup complete."
