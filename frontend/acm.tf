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
