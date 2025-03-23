#!/bin/bash

# System update
apt update && apt upgrade -y

# Install Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker

# Install Docker Compose (v2)
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add the user to the docker group
usermod -aG docker ubuntu

# Download the Docker Compose configuration file and start the containers
docker pull <votre-image-backend>
docker run -d --name backend -p 3000:3000 <votre-image-backend>