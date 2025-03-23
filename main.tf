terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-anthonyrovira"
    key            = "global/terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region = "eu-west-3" 
}