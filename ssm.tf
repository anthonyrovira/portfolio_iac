resource "aws_ssm_parameter" "dockerhub_username" {
  name        = "/portfolio/dockerhub/username"
  description = "Docker Hub username"
  type        = "SecureString"
  value       = var.dockerhub_username
}

resource "aws_ssm_parameter" "dockerhub_password" {
  name        = "/portfolio/dockerhub/password"
  description = "Docker Hub password"
  type        = "SecureString"
  value       = var.dockerhub_password
}

resource "aws_ssm_parameter" "backend_secrets" {
  for_each = {
    upstash_redis_rest_url   = var.upstash_redis_rest_url
    upstash_redis_rest_token = var.upstash_redis_rest_token

    firebase_api_key             = var.firebase_api_key
    firebase_auth_domain         = var.firebase_auth_domain
    firebase_project_id          = var.firebase_project_id
    firebase_storage_bucket      = var.firebase_storage_bucket
    firebase_messaging_sender_id = var.firebase_messaging_sender_id
    firebase_app_id              = var.firebase_app_id
    firebase_measurement_id      = var.firebase_measurement_id

    resend_api_key    = var.resend_api_key
    resend_from_email = var.resend_from_email
    allowed_origin    = var.allowed_origin

    gf_security_admin_user     = var.gf_security_admin_user
    gf_security_admin_password = var.gf_security_admin_password

    aws_access_key_id     = var.aws_access_key_id
    aws_secret_access_key = var.aws_secret_access_key
  }

  name        = "/portfolio/${each.key}"
  type        = "SecureString"
  value       = each.value
  description = "Secret ${each.key}"

  tags = {
    Environment = "production"
  }
}
