#!/bin/bash
# User Data Script - Portfolio Backend Deployment
# Version: 1.0
# Description: Configures EC2 instance for Docker/ECR deployment

# ----------------------------
# 1. SYSTEM SETUP
# ----------------------------
echo "==> Starting system update..."
sudo apt update && sudo apt upgrade -y

echo "==> Installing base packages..."
sudo apt install -y \
    awscli \
    docker.io \
    curl \
    wget \
    git \
    amazon-ecr-credential-helper

# ----------------------------
# 2. DOCKER CONFIGURATION
# ----------------------------
echo "==> Setting up Docker..."

# Install Docker Compose v2
echo "--> Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configure ECR helper
echo "--> Configuring ECR credentials..."
mkdir -p ~/.docker
echo '{"credsStore": "ecr-login"}' > ~/.docker/config.json
sudo chown -R ubuntu:ubuntu ~/.docker

# Start Docker service
echo "--> Starting Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

# ----------------------------
# 3. APPLICATION SETUP
# ----------------------------
echo "==> Preparing application environment..."
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# ----------------------------
# 4. ECR LOGIN
# ----------------------------
echo "==> Logging into ECR..."

sudo aws ecr get-login-password --region "$region" | \
    sudo docker login --username AWS --password-stdin "$ecr_registry"

# ----------------------------
# 5. COMPLETION
# ----------------------------
echo "==> Script completed successfully!"
echo "User data script completed at $(date)" > /var/log/user-data.log

# sudo tail -f /var/log/cloud-init-output.log
