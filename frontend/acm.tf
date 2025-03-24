#   arn      = "arn:aws:acm:us-east-1:717119779577:certificate/15724fba-d3e0-4e70-812b-c6426dd0a61a"

# Find a certificate that is issued
data "aws_acm_certificate" "issued" {
  domain   = "anthonyrovira.com"
  statuses = ["ISSUED"]
  provider = aws.us-east-1
}

# Find a certificate issued by (not imported into) ACM
# data "aws_acm_certificate" "amazon_issued" {
#   domain      = "anthonyrovira.com"
#   types       = ["AMAZON_ISSUED"]
#   most_recent = true
#   provider = aws.us-east-1
# }

# Find a RSA 2048 bit certificate
# data "aws_acm_certificate" "rsa_2048" {
#   domain    = "anthonyrovira.com"
#   key_types = ["RSA_2048"]
#   provider = aws.us-east-1
# }