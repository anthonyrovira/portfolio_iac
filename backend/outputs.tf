output "ec2_public_ip" {
  description = "EC2 Backend Instance Public IP"
  value       = aws_instance.backend.public_ip
} 