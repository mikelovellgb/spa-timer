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
