provider "aws" {
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  required_version = "~>1.0.0"

  backend "s3" {
    region  = "ap-northeast-1"
    bucket  = "kou-terraform-aws-eks"
    key     = "terraform.tfstate"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.46.0"
    }
  }
}
