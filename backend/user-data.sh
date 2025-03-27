#!/bin/bash

# System update
echo "==> Updating system..."
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    awscli \
    curl \
    wget 

# Install Nvm, Node.js, Pnpm and PM2
echo "==> Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

node -v && npm -v
sudo systemctl restart packagekit.service

sudo npm install -g pnpm@8.15.4
pnpm -v

sudo npm install -g pm2@6.0.5
pm2 -v

sudo pm2 startup
pm2 save

# Create directory for the application
echo "==> Cleaning previous deployment..."
rm -rf /home/ubuntu/app
mkdir -p /home/ubuntu/app
chown -R ubuntu:ubuntu /home/ubuntu/app

echo "==> Script completed successfully!"
echo "User data script completed at $(date)" > /var/log/user-data.log

# sudo tail -f /var/log/cloud-init-output.log
