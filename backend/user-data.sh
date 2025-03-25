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

# Install Nginx
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install Amazon ECR Credential Helper
sudo apt install -y amazon-ecr-credential-helper
sudo systemctl restart packagekit.service

# Configure Docker to use the Amazon ECR Credential Helper
sudo mkdir -p ~/.docker
sudo echo '{"credsStore": "ecr-login"}' > ~/.docker/config.json
sudo chown -R ubuntu:ubuntu /home/ubuntu/.docker

# Start and enable Docker
sudo systemctl restart docker
sudo systemctl enable docker

# Install Docker Compose (v2)
sudo curl -L https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add the user to the docker group
sudo usermod -aG docker ubuntu

# Create directory for the application
sudo mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# Configure Nginx reverse proxy 
sudo tee /etc/nginx/conf.d/backend.conf > /dev/null <<'EOT'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOT

sudo systemctl restart nginx

echo "User data script completed successfully" > /var/log/user-data.log