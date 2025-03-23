output "ec2_public_ip" {
  description = "EC2 Backend Instance Public IP"
  value       = aws_instance.backend.public_ip
}

output "frontend_url" {
  description = "Production URL of the frontend"
  value       = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}