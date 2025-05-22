#!/usr/bin/env bash
# 03_build_and_deploy_web.sh
#
# Builds and deploys the Spa Timer Next.js web app as a systemd service.
# - Pulls latest code from git and ensures scripts are executable
# - Installs npm dependencies
# - Builds the Next.js app
# - Creates/updates a systemd service for the app
# - Enables and starts the service, showing status
#
# Usage: Run as the deploy user (with sudo for systemd steps). Assumes app is in ~/spa-timer.
#
# This script automates deployment and service management for the Spa Timer web app.

set -euo pipefail

# Always operate in the user's spa-timer directory
cd "${HOME}/spa-timer"

# Pull latest code from git before building
if [ -d .git ]; then
  echo "Pulling latest code from git..."
  git fetch origin
  git reset --hard origin/main
  git pull
  # Ensure all scripts are executable after pulling
  echo "Making all scripts in ./scripts executable..."
  chmod +x ./scripts/*.sh
else
  echo "No git repository found. Skipping git pull."
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the app using npx to avoid permission issues
echo "Building the app..."
if command -v npx >/dev/null 2>&1; then
  npx next build
else
  node node_modules/next/dist/bin/next build
fi

echo "Build complete!"

# If room.json exists in the user's home directory, copy it to public/ and overwrite
if [ -f "${HOME}/room.json" ]; then
  echo "Copying ~/room.json to public/ (overwriting if exists)..."
  cp -f "${HOME}/room.json" "${HOME}/spa-timer/public/room.json"
fi

# -------------------------------------------------------------------
# deploy.sh
#!/usr/bin/env bash
# Deploys, registers and starts the systemd service for the spa-timer app
set -euo pipefail

# Application directory and current user
dir="${HOME}/spa-timer"
user="$(id -un)"
service_name="spa-timer"

# Create systemd service unit
cat <<EOF | sudo tee /etc/systemd/system/${service_name}.service > /dev/null
[Unit]
Description=SPA Timer App
After=network.target

[Service]
Type=simple
User=${user}
WorkingDirectory=${dir}
ExecStart=/usr/bin/env npm start
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable/start the service
echo "Reloading systemd configuration..."
sudo systemctl daemon-reload

echo "Enabling ${service_name} to start on boot..."
sudo systemctl enable ${service_name}

echo "Starting (or restarting) ${service_name}..."
sudo systemctl restart ${service_name}

echo "Deployment complete! Service status:"
sudo systemctl status ${service_name} --no-pager
