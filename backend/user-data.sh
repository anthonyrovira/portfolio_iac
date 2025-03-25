#!/bin/bash

# System update
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install docker.io -y
sudo apt install awscli -y
sudo apt install curl -y
sudo apt install wget -y
sudo apt install git -y

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Install Docker Compose (v2)
sudo curl -L https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add the user to the docker group
sudo usermod -aG docker ubuntu

# Create directory for the application
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

echo "User data script completed successfully" > /var/log/user-data.log