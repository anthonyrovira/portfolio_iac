resource "aws_instance" "backend" {
  ami                  = "ami-0ff71843f814379b3"
  instance_type        = "t2.micro"
  key_name             = "backend-key"
  iam_instance_profile = aws_iam_instance_profile.ec2_backend_profile.name
  security_groups      = [aws_security_group.backend_sg.id]
  subnet_id            = aws_subnet.public.id
  depends_on           = [data.aws_route53_zone.main, aws_ssm_parameter.backend_secrets]

  provisioner "file" {
    source      = "docker-compose.yml"
    destination = "/tmp/docker-compose.yml"
  }
  provisioner "file" {
    source      = "prometheus.yml"
    destination = "/tmp/prometheus.yml"
  }
  provisioner "file" {
    source      = "nginx.conf"
    destination = "/tmp/nginx.conf"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("backend-key.pem")
  }

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
    gf_security_admin_user       = aws_ssm_parameter.backend_secrets["gf_security_admin_user"].name,
    gf_security_admin_password   = aws_ssm_parameter.backend_secrets["gf_security_admin_password"].name,
    aws_access_key_id            = aws_ssm_parameter.backend_secrets["aws_access_key_id"].name,
    aws_secret_access_key        = aws_ssm_parameter.backend_secrets["aws_secret_access_key"].name,
    aws_region                   = var.aws_region,
    aws_hosted_zone_id           = data.aws_route53_zone.main.zone_id
  })

  tags = {
    Name = "${var.project_name}-backend"
  }
}
