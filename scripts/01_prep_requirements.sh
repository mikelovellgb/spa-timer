#!/usr/bin/env bash
# 01_prep_requirements.sh
#
# Prepares a fresh Debian/Ubuntu system for running the Spa Timer web app.
#
# This script will:
#   - Update and upgrade system packages
#   - Install core tools: git, curl, build-essential
#   - Install Node.js 18.x and npm
#   - Create a default ~/room.json file (if not present) for the timer room name
#   - Verify Node.js and npm installation
#
# Usage: Run as root or with sudo privileges on a fresh system.
#
# After running this script, proceed with the remaining setup scripts in the 'scripts/' directory.
#
# This script is intended for Debian/Ubuntu-based systems only.

# Update & install core tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential

# Install Node.js 18.x (includes npm)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash –
sudo apt install -y nodejs
sudo apt install -y npm

# Create a default room.json in the user's home directory if it doesn't exist
if [ ! -f "$HOME/room.json" ]; then
  echo '{ "roomName": "Default" }' > "$HOME/room.json"
  echo "Created default $HOME/room.json with roomName: Spa Room"
fi

# Verify
node -v   # should be ≥ v18.x
npm -v
