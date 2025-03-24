#!/bin/bash

# System update
sudo apt update && apt upgrade -y

# Install AWS CLI
sudo apt install -y awscli

# Install Docker
sudo apt install -y docker.io
systemctl start docker
systemctl enable docker

# Install Docker Compose (v2)
sudo mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add the user to the docker group
sudo usermod -aG docker ubuntu

# Connect to the ECR repository
AWS_ACCOUNT_ID="<AWS_ACCOUNT_ID>"
REGION="eu-west-3"
IMAGE_NAME="portfolio-backend"

sudo aws ecr get-login-password --region $REGION | sudo docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

IMAGE_TAG="latest"
ECR_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_NAME:$IMAGE_TAG"

sudo docker stop backend || true
sudo docker rm backend || true

sudo docker pull $ECR_IMAGE

sudo docker run -d \
  --name backend \
  -p 3000:3000 \
  --env-file /home/ubuntu/.env \
  $ECR_IMAGE