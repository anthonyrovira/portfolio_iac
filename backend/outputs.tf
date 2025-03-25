output "ec2_public_ip" {
  description = "EC2 Backend Instance Public IP"
  value       = aws_instance.backend.public_ip
} 

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}