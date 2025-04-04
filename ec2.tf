resource "aws_instance" "backend" {
  ami                  = "ami-0ff71843f814379b3"
  instance_type        = "t2.micro"
  key_name             = "backend-key"
  iam_instance_profile = aws_iam_instance_profile.ec2_backend_profile.name
  security_groups      = [aws_security_group.backend_sg.id]
  subnet_id            = aws_subnet.public.id

  user_data_replace_on_change = true
  user_data = templatefile("${path.module}/user-data.sh", {
    ssm_username_param           = aws_ssm_parameter.dockerhub_username.name,
    ssm_password_param           = aws_ssm_parameter.dockerhub_password.name,
    upstash_redis_rest_url       = aws_ssm_parameter.backend_secrets["upstash_redis_rest_url"].name,
    upstash_redis_rest_token     = aws_ssm_parameter.backend_secrets["upstash_redis_rest_token"].name,
    firebase_api_key             = aws_ssm_parameter.backend_secrets["firebase_api_key"].name,
    firebase_auth_domain         = aws_ssm_parameter.backend_secrets["firebase_auth_domain"].name,
    firebase_project_id          = aws_ssm_parameter.backend_secrets["firebase_project_id"].name,
    firebase_storage_bucket      = aws_ssm_parameter.backend_secrets["firebase_storage_bucket"].name,
    firebase_messaging_sender_id = aws_ssm_parameter.backend_secrets["firebase_messaging_sender_id"].name,
    firebase_app_id              = aws_ssm_parameter.backend_secrets["firebase_app_id"].name,
    firebase_measurement_id      = aws_ssm_parameter.backend_secrets["firebase_measurement_id"].name,
    resend_api_key               = aws_ssm_parameter.backend_secrets["resend_api_key"].name,
    resend_from_email            = aws_ssm_parameter.backend_secrets["resend_from_email"].name,
    allowed_origin               = aws_ssm_parameter.backend_secrets["allowed_origin"].name,
    aws_region                   = var.aws_region
  })

  tags = {
    Name = "${var.project_name}-backend"
  }
}
