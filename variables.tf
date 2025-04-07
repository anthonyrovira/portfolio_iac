variable "project_name" {
  default = "portfolio"
  type    = string
}

variable "domain" {
  default = "anthonyrovira.com"
  type    = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-3"
}


# variable "cloudflare_api_token" {
#   description = "Cloudflare API token"
#   type        = string
#   sensitive   = true
# }

# variable "cloudflare_account_id" {
#   description = "Cloudflare account ID"
#   type        = string
#   sensitive   = true
# }

# variable "cloudflare_zone_id" {
#   description = "Cloudflare zone ID"
#   type        = string
#   sensitive   = true
# }

variable "dockerhub_username" {
  description = "Docker Hub username"
  type        = string
  sensitive   = true
}

variable "dockerhub_password" {
  description = "Docker Hub password"
  type        = string
  sensitive   = true
}

variable "gf_security_admin_user" {
  description = "Grafana username"
  type        = string
  sensitive   = true
}

variable "gf_security_admin_password" {
  description = "Grafana password"
  type        = string
  sensitive   = true
}

variable "upstash_redis_rest_url" {
  description = "Upstash Redis REST URL"
  type        = string
  sensitive   = true
}

variable "upstash_redis_rest_token" {
  description = "Upstash Redis REST token"
  type        = string
  sensitive   = true
}

variable "firebase_api_key" {
  description = "Firebase API key"
  type        = string
  sensitive   = true
}

variable "firebase_project_id" {
  description = "Firebase project ID"
  type        = string
}

variable "firebase_auth_domain" {
  description = "Firebase auth domain"
  type        = string
}

variable "resend_api_key" {
  description = "Resend API key"
  type        = string
  sensitive   = true
}

variable "resend_from_email" {
  description = "Resend from email"
  type        = string
  sensitive   = true
}

variable "firebase_storage_bucket" {
  description = "Firebase storage bucket"
  type        = string
  sensitive   = true
}

variable "firebase_messaging_sender_id" {
  description = "Firebase messaging sender ID"
  type        = string
  sensitive   = true
}

variable "firebase_app_id" {
  description = "Firebase app ID"
  type        = string
  sensitive   = true
}

variable "firebase_measurement_id" {
  description = "Firebase measurement ID"
  type        = string
  sensitive   = true
}

variable "allowed_origin" {
  description = "Allowed origin"
  type        = string
  sensitive   = true
}

variable "aws_access_key_id" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}
