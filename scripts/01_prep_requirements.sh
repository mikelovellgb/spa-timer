#!/usr/bin/env bash
# 01_prep_requirements.sh
#
# Prepares the system for running the Spa Timer web app.
# - Updates and upgrades system packages
# - Installs core tools: git, curl, build-essential
# - Installs Node.js 18.x and npm
# - Verifies Node.js and npm installation
#
# Usage: Run as root or with sudo privileges on a fresh system.
#
# This script is intended for Debian/Ubuntu-based systems.

# Update & install core tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential

# Install Node.js 18.x (includes npm)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash –
sudo apt install -y nodejs
sudo apt install -y npm

# Verify
node -v   # should be ≥ v18.x
npm -v
