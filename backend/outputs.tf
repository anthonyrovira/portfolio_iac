output "ec2_public_dns" {
  description = "EC2 Backend Instance Public IP"
  value       = aws_instance.backend.public_dns
} 

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}