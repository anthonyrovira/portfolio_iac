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

# Configure watchtower
echo "--> Configuring Watchtower..."    
docker run -d \
  --name watchtower \
  -e REPO_USER=$DOCKERHUB_USERNAME -e REPO_PASS=$DOCKERHUB_PASSWORD \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e WATCHTOWER_LABEL_ENABLE=true \
  -e WATCHTOWER_SCOPE=traefik_network \
  containrrr/watchtower \
  --interval 60 \
  --cleanup \
  --include-stopped \
  --debug \
  portfolio-backend

# Create a dedicated network
echo "--> Creating a dedicated network..."
docker network create traefik_network

# Configure Backend app
echo "--> Configuring Backend app..."
docker run -d \
  --name traefik \
  --network traefik_network \
  -p 80:80 \
  -p 443:443 \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /opt/traefik/letsencrypt:/letsencrypt \
  traefik:v3.3 \
  --providers.docker=true \
  --entrypoints.web.address=:80 \
  --entrypoints.websecure.address=:443 \
  --entrypoints.web.http.redirections.entrypoint.to=websecure \
  --entrypoints.web.http.redirections.entrypoint.scheme=https \
  --certificatesresolvers.myresolver.acme.email=anthonyrov@gmail.com \
  --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json \
  --certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web \
  --certificatesresolvers.myresolver.acme.keytype=EC256

docker run -d \
  --name portfolio-backend \
  --network traefik_network \
  -l traefik.enable=true \
  -l "traefik.http.routers.backend.rule=Host(\`api.anthonyrovira.com\`)" \
  -l traefik.http.routers.backend.entrypoints=websecure \
  -l traefik.http.routers.backend.tls.certresolver=myresolver \
  -l traefik.http.services.backend.loadbalancer.server.port=3000 \
  --env-file /home/ubuntu/app/.env \
  -e NODE_ENV=production \
  hysteria9/portfolio-backend:latest

echo "==> Script completed successfully!"
echo "User data script completed at $(date)" > /var/log/user-data.log

# sudo tail -f /var/log/cloud-init-output.log
# journalctl -u pm2-ubuntu.service -n 100 --no-pager
# dig api.anthonyrovira.com +short
# docker exec traefik cat /letsencrypt/acme.json
# curl -vk https://api.anthonyrovira.com