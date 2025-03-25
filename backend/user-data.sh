#!/bin/bash

# System update
sudo apt update && apt upgrade -y

# Install required packages
sudo apt install -y \
    awscli \
    docker.io \
    curl \
    wget \
    git

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose (v2)
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add the user to the docker group
sudo usermod -aG docker ubuntu

# Create directory for the application
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# Connect to the ECR repository
AWS_ACCOUNT_ID="717119779577"
REGION="eu-west-3"
IMAGE_NAME="portfolio-backend"

sudo aws ecr get-login-password --region $REGION | sudo docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Create .env file with placeholder (will be updated by GitHub Actions)
sudo touch /home/ubuntu/.env
sudo chown ubuntu:ubuntu /home/ubuntu/.env

# Create docker-compose.yml with placeholder (will be updated by GitHub Actions)
sudo touch /home/ubuntu/docker-compose.yml
sudo chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml

# Set proper permissions for SSH key (if needed for GitHub Actions)
sudo mkdir -p /home/ubuntu/.ssh
sudo chmod 700 /home/ubuntu/.ssh
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# # Install healthcheck dependencies
# sudo apt install -y wget

# # Create a basic healthcheck script
# sudo tee /usr/local/bin/healthcheck.sh << 'EOF'
# #!/bin/bash
# wget --spider http://localhost:3000/health
# EOF
# sudo chmod +x /usr/local/bin/healthcheck.sh

# # Create systemd service for healthcheck
# sudo tee /etc/systemd/system/healthcheck.service << 'EOF'
# [Unit]
# Description=Portfolio Backend Healthcheck
# After=docker.service

# [Service]
# Type=simple
# User=ubuntu
# ExecStart=/usr/local/bin/healthcheck.sh
# Restart=always
# RestartSec=30

# [Install]
# WantedBy=multi-user.target
# EOF

# # Enable and start healthcheck service
# sudo systemctl enable healthcheck.service
# sudo systemctl start healthcheck.service