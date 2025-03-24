output "ec2_public_ip" {
  description = "EC2 Backend Instance Public IP"
  value       = module.backend.ec2_public_ip 
}

output "frontend_url" {
  description = "Production URL of the frontend"
  value       = module.frontend.frontend_url 
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.frontend.s3_bucket_arn
}