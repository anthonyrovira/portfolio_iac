#!/bin/bash

# System update
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    awscli \
    docker.io \
    curl \
    wget \
    git


# Install Amazon ECR Credential Helper
sudo apt install -y amazon-ecr-credential-helper
sudo systemctl restart packagekit.service

# Install Docker Compose (v2)
sudo curl -L https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Configure Docker to use the Amazon ECR Credential Helper
sudo mkdir -p /home/ubuntu/.docker
echo '{"credsStore": "ecr-login"}' | sudo tee /home/ubuntu/.docker/config.json
sudo chown -R ubuntu:ubuntu /home/ubuntu/.docker

# Start and enable Docker
sudo systemctl restart docker
sudo systemctl enable docker

# Add the user to the docker group
sudo usermod -aG docker ubuntu

# Create directory for the application
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# Login to Amazon ECR
sudo aws ecr get-login-password --region "${region}" | sudo docker login --username AWS --password-stdin "${ecr_registry}"

echo "==> Script completed successfully!"
echo "User data script completed at $(date)" > /var/log/user-data.log

# sudo tail -f /var/log/cloud-init-output.log
