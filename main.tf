terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "anthonyrovira-frontend"
    key            = "global/terraform.tfstate"
    region         = "eu-west-3"
  }
}

provider "aws" {
  region = "eu-west-3"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"  # Mandatory for ACM certificates
}

module "backend" {
  source = "./backend"
  providers = {
    aws = aws
  }
}

module "frontend" {
  source = "./frontend"
  providers = {
    aws = aws
    aws.us-east-1 = aws.us-east-1
  }
}