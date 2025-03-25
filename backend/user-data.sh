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

# Connect to the ECR repository
AWS_ACCOUNT_ID="717119779577"
REGION="eu-west-3"

sudo aws ecr get-login-password --region $REGION | sudo docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "User data script completed successfully" > /var/log/user-data.log