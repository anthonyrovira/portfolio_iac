resource "aws_iam_role" "ec2_backend" {
  name = "ec2-backend-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Sid    = ""
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "ec2-backend-role"
  }
}

resource "aws_iam_instance_profile" "ec2_backend" {
  name = "ec2_backend"
  role = aws_iam_role.ec2_backend.name
}

resource "aws_iam_role_policy_attachment" "ec2_backend" {
  role       = aws_iam_role.ec2_backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}