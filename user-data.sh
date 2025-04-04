#!/bin/bash

# System update
echo "==> Updating system..."
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    awscli \
    curl \
    docker.io \
    wget 

# Install Docker Compose v2
echo "--> Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.26.1/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Create directory for the application
echo "==> Setting up requiered directories..."
mkdir -p /opt/traefik/letsencrypt
sudo chown -R 1000:1000 /opt/traefik/letsencrypt
sudo chmod 755 /opt/traefik

mkdir -p /home/ubuntu/app
sudo chown -R ubuntu:ubuntu /home/ubuntu/app

# Starting docker
echo "--> Starting Docker..."
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu

# Get Docker Hub credentials from SSM
echo "--> Fetching Docker Hub credentials..."
DOCKERHUB_USERNAME=$(aws ssm get-parameter --name "${ssm_username_param}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
DOCKERHUB_PASSWORD=$(aws ssm get-parameter --name "${ssm_password_param}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)

# Login docker
echo "--> Logging in to Docker Hub..."
echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

# Getting env variables from SSM
echo "--> Getting environment variables from SSM"
cat << EOF > /home/ubuntu/app/.env
UPSTASH_REDIS_REST_URL=$(aws ssm get-parameter --name "${upstash_redis_rest_url}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
UPSTASH_REDIS_REST_TOKEN=$(aws ssm get-parameter --name "${upstash_redis_rest_token}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_API_KEY=$(aws ssm get-parameter --name "${firebase_api_key}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_AUTH_DOMAIN=$(aws ssm get-parameter --name "${firebase_auth_domain}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_PROJECT_ID=$(aws ssm get-parameter --name "${firebase_project_id}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_STORAGE_BUCKET=$(aws ssm get-parameter --name "${firebase_storage_bucket}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_MESSAGING_SENDER_ID=$(aws ssm get-parameter --name "${firebase_messaging_sender_id}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_APP_ID=$(aws ssm get-parameter --name "${firebase_app_id}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
FIREBASE_MEASUREMENT_ID=$(aws ssm get-parameter --name "${firebase_measurement_id}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
RESEND_API_KEY=$(aws ssm get-parameter --name "${resend_api_key}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
RESEND_FROM_EMAIL=$(aws ssm get-parameter --name "${resend_from_email}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
ALLOWED_ORIGIN=$(aws ssm get-parameter --name "${allowed_origin}" --with-decryption --query "Parameter.Value" --region ${aws_region} --output text)
EOF
sudo chmod 600 /home/ubuntu/app/.env

# Copy docker-compose.yml to ec2
echo "--> Deploying Docker Compose configuration"
mkdir -p /opt/docker
mv /tmp/docker-compose.yml /opt/docker/docker-compose.yml

# Service launch
echo "--> Starting services with Docker Compose"
cd /opt/docker
docker-compose up -d

echo "==> Script completed successfully!"
echo "User data script completed at $(date)" > /var/log/user-data.log

# sudo tail -f /var/log/cloud-init-output.log
# journalctl -u pm2-ubuntu.service -n 100 --no-pager
# dig api.anthonyrovira.com +short
# docker exec traefik cat /letsencrypt/acme.json
# curl -vk https://api.anthonyrovira.com