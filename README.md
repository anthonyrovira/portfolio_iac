# Portfolio Infrastructure - AWS, Terraform, Docker, Nginx

This repository contains the Infrastructure as Code (IaC) using Terraform to deploy and manage the infrastructure for a personal portfolio website and its associated backend services on AWS.

## Architecture Overview

The infrastructure consists of the following main components:

1.  **Frontend:**
    *   Static website content (React/Next.js, etc.) hosted in an **AWS S3 bucket**.
    *   Served globally via **AWS CloudFront** for low latency and HTTPS (using an ACM certificate).
    *   Includes a CloudFront Function to redirect `www.` traffic to the root domain.
    *   Security headers are applied via a CloudFront Response Headers Policy.

2.  **Backend & Monitoring Services:**
    *   Runs on a single **AWS EC2 instance** within a VPC.
    *   Services are containerized using **Docker** and managed with **Docker Compose**.
    *   **Nginx** container acts as an internal reverse proxy, receiving HTTP traffic from CloudFront (on port 80) and directing it to the appropriate backend service.
    *   **Portfolio Backend:** A custom HonoJS application (`portfolio-backend`) serving the API.
    *   **Prometheus:** Collects metrics from Node Exporter, the backend application, and itself. Accessed via CloudFront and secured with HTTP Basic Authentication at the Nginx level.
    *   **Grafana:** Visualizes metrics collected by Prometheus. Accessed via CloudFront and potentially secured with HTTP Basic Authentication or IP allow-listing at the Nginx level.
    *   **Node Exporter:** Exposes host-level metrics from the EC2 instance.
    *   **Watchtower:** Automatically updates running Docker containers to their latest image (consider using specific tags and monitoring instead for production).
    *   **CloudFront (Backend):** A separate distribution points to the EC2 instance (via its public DNS) as an origin, providing HTTPS termination (ACM certificate) and potentially AWS WAF protection for the backend, Grafana, and Prometheus endpoints.

3.  **Networking & Security:**
    *   **VPC:** Custom VPC with public and private subnets (though only public seems used currently).
    *   **Security Groups:** Restricts access to the EC2 instance. SSH (port 22) is limited to a specific IP. HTTP (port 80) should be limited to CloudFront IP ranges.
    *   **Route 53:** Manages DNS records for the frontend, API, Grafana, and Prometheus subdomains, pointing them to the respective CloudFront distributions.
    *   **AWS Certificate Manager (ACM):** Provides the public SSL/TLS certificates used by the CloudFront distributions.
    *   **AWS Systems Manager (SSM) Parameter Store:** Securely stores application secrets, Docker Hub credentials, and AWS credentials (if needed for specific tasks within the instance, though IAM roles are preferred).
    *   **IAM:** Defines roles and permissions for the EC2 instance (to access SSM) and potentially for CI/CD (e.g., GitHub Actions using OIDC is recommended over access keys).

4.  **Deployment & Management:**
    *   **Terraform:** Used to define and provision all AWS resources.
    *   **EC2 User Data:** A shell script (`user-data.sh`) runs on instance launch to install Docker, Docker Compose, AWS CLI, fetch secrets from SSM, configure Docker login, create necessary directories, generate `.htpasswd` files, and start the Docker Compose services.

## Technologies Used

*   **Cloud Provider:** AWS
*   **IaC:** Terraform
*   **Containerization:** Docker, Docker Compose
*   **Web Server/Reverse Proxy:** Nginx
*   **Backend:** HonoJS
*   **Monitoring:** Prometheus, Grafana, Node Exporter
*   **CI/CD:** GitHub Actions
  

## Accessing Services

*   **Frontend:** `https://anthonyrovira.com`
*   **Backend API:** `https://api.anthonyrovira.com`
*   **Grafana:** `https://grafana.api.anthonyrovira.com` (Requires authentication)

## Monitoring

Metrics are scraped by Prometheus and can be visualized in Grafana.
