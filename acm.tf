provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

data "aws_acm_certificate" "issued" {
  domain   = "anthonyrovira.com"
  statuses = ["ISSUED"]
  provider = aws.virginia
}
