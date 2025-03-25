resource "aws_instance" "backend" {
  ami                    = "ami-0ff71843f814379b3" 
  instance_type          = "t2.micro"
  key_name               = "backend-key"
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_backend.name

  user_data = templatefile("${path.module}/user-data.sh", {
    ecr_registry = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com",
    region       = var.aws_region
  })

  tags = {
    Name = "portfolio-backend"
  }
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}
