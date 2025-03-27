resource "aws_instance" "backend" {
  ami                    = "ami-0ff71843f814379b3" 
  instance_type          = "t2.micro"
  key_name               = "backend-key"
  security_groups = [aws_security_group.backend_sg.name]
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_backend.name

  user_data = file("${path.module}/user-data.sh")   

  tags = {
    Name = "portfolio-backend"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
