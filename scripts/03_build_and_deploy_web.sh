# build.sh
#!/usr/bin/env bash
# Builds the Next.js app in ~/spa-timer (clean before building)
set -euo pipefail

# Always operate in the user's spa-timer directory
cd "${HOME}/spa-timer"

# Clean previous build artifacts and dependencies
echo "Cleaning previous build artifacts and node_modules..."
rm -rf node_modules .next

# Pull latest code from git before building
if [ -d .git ]; then
  echo "Pulling latest code from git..."
  git fetch origin
  git reset --hard origin/main
  git pull
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
