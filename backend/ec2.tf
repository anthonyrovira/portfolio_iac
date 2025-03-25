resource "aws_instance" "backend" {
  ami                    = "ami-0160e8d70ebc43ee1" 
  instance_type          = "t2.micro"
  key_name               = "backend-key"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_backend.name

  user_data = file("${path.module}/user-data.sh")

  tags = {
    Name = "portfolio-backend"
  }
}
