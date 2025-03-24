# Infrastructure as Code for anthonyrovira.com

This repository contains the Terraform configuration for the infrastructure of my portfolio website, anthonyrovira.com. The infrastructure is deployed on AWS and consists of a frontend and backend setup.

## Architecture Overview

### Frontend

- **S3 Bucket**: Hosts the static website files
- **CloudFront Distribution**: Provides CDN capabilities and HTTPS
- **ACM Certificate**: SSL/TLS certificate for secure HTTPS connections
- **IAM Roles**: Manages access permissions for S3 and CloudFront

### Backend

- **EC2 Instance**: Hosts the backend application
- **Security Group**: Controls inbound/outbound traffic
- **IAM Roles**: Manages EC2 instance permissions

## Infrastructure Details

### Frontend Components

- **S3 Bucket**:

  - Name: `anthonyrovira-frontend`
  - Private access with CloudFront OAI
  - Website hosting enabled
  - Versioning enabled

- **CloudFront Distribution**:
  - Custom domain: anthonyrovira.com
  - HTTPS enabled with custom certificate
  - Geo-restricted access (whitelisted countries)
  - Optimized caching configuration

### Backend Components

- **EC2 Instance**:

  - Instance type: t2.micro
  - AMI: Ubuntu Server
  - User data script for Docker setup
  - Public IP enabled

- **Security Group**:
  - Port 3000 open for application access
  - Port 22 open for SSH access
  - All outbound traffic allowed

## Deployment

### Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed
- Domain name registered and configured

### Deployment Steps

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Review the planned changes:

   ```bash
   terraform plan
   ```

3. Apply the infrastructure:
   ```bash
   terraform apply
   ```

### Outputs

After successful deployment, the following outputs will be available:

- `ec2_public_ip`: Public IP of the backend instance
- `frontend_url`: Production URL of the frontend
- `s3_bucket_arn`: ARN of the S3 bucket

## Security Considerations

- Private S3 bucket with CloudFront OAI
- HTTPS enforced through CloudFront
- Geo-restricted access
- Minimal security group rules
- IAM roles following least privilege principle
