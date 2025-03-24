resource "aws_ecr_repository" "backend" {
  name = "portfolio-backend"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = "production"
  }
}