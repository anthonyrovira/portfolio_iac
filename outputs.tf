output "frontend_url" {
  description = "Production Frontend URL"
  value       = "https://${var.domain}"
}

# output "s3_bucket_name" {
#   description = "Frontend S3 bucket name for CI/CD sync"
#   value       = aws_s3_bucket.frontend.bucket
# }

output "ec2_instance_id" {
  description = "Backend EC2 instance public ip"
  value       = "https://${aws_instance.backend.public_ip}"
}
