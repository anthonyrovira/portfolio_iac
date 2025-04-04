# EC2 Instance Role & Permissions
resource "aws_iam_role" "ec2_backend_role" {
  name = "${var.project_name}-ec2-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_backend_profile" {
  name = "${var.project_name}-ec2-backend-profile"
  role = aws_iam_role.ec2_backend_role.name
}

resource "aws_iam_role_policy" "ssm_read_access" {
  name = "${var.project_name}-ssm-read-access"
  role = aws_iam_role.ec2_backend_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Effect = "Allow",
        Resource = [
          aws_ssm_parameter.dockerhub_username.arn,
          aws_ssm_parameter.dockerhub_password.arn,
          aws_ssm_parameter.backend_secrets["upstash_redis_rest_url"].arn,
          aws_ssm_parameter.backend_secrets["upstash_redis_rest_token"].arn,
          aws_ssm_parameter.backend_secrets["firebase_api_key"].arn,
          aws_ssm_parameter.backend_secrets["firebase_auth_domain"].arn,
          aws_ssm_parameter.backend_secrets["firebase_project_id"].arn,
          aws_ssm_parameter.backend_secrets["firebase_storage_bucket"].arn,
          aws_ssm_parameter.backend_secrets["firebase_messaging_sender_id"].arn,
          aws_ssm_parameter.backend_secrets["firebase_app_id"].arn,
          aws_ssm_parameter.backend_secrets["firebase_measurement_id"].arn,
          aws_ssm_parameter.backend_secrets["resend_api_key"].arn,
          aws_ssm_parameter.backend_secrets["resend_from_email"].arn,
          aws_ssm_parameter.backend_secrets["allowed_origin"].arn
        ]
      }
    ]
  })
}
