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
          aws_ssm_parameter.backend_secrets["allowed_origin"].arn,
          aws_ssm_parameter.backend_secrets["gf_security_admin_user"].arn,
          aws_ssm_parameter.backend_secrets["gf_security_admin_password"].arn,
          aws_ssm_parameter.backend_secrets["aws_access_key_id"].arn,
          aws_ssm_parameter.backend_secrets["aws_secret_access_key"].arn
        ]
      }
    ]
  })
}

# Bucket S3 and Cloudfront Role & Permissions

# GitHub Actions permission 
data "aws_iam_policy_document" "github_actions" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "${aws_s3_bucket.frontend.arn}/*",
      aws_s3_bucket.frontend.arn
    ]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetDistribution"
    ]
    resources = [aws_cloudfront_distribution.frontend.arn]
  }
}

resource "aws_iam_user" "github_actions" {
  name = "github-actions-frontend"
}

resource "aws_iam_user_policy" "github_actions" {
  user   = aws_iam_user.github_actions.name
  policy = data.aws_iam_policy_document.github_actions.json
}

# Access Key for GitHub Actions
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "aws_iam_role_policy" "route53_permissions" {
  name = "${var.project_name}-route53-permissions"
  role = aws_iam_role.ec2_backend_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:GetChange",
          "route53:ListHostedZones",
          "route53:ListHostedZonesByName",
          "route53:ListResourceRecordSets",
          "route53:ChangeResourceRecordSets"
        ],
        "Resource" : "*"
      }
    ]
  })
}



