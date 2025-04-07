output "frontend_url" {
  description = "Production Frontend URL"
  value       = "https://${var.domain}"
}

output "ec2_instance_id" {
  description = "Backend EC2 instance public ip"
  value       = "https://${aws_instance.backend.public_ip}"
}
