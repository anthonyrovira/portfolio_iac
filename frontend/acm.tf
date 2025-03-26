resource "aws_acm_certificate" "frontend" {
  domain_name       = "anthonyrovira.com"
  subject_alternative_names = ["www.anthonyrovira.com"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  provider = aws.us-east-1
}