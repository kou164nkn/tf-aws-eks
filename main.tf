provider "aws" {
  version    = "~> 3.0"
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

terraform {
  required_version = ">=0.12.0"

  backend "s3" {
    region  = "ap-northeast-1"
    bucket  = "kou-terraform-aws-eks"
    key     = "terraform.tfstate"
    encrypt = true
  }
}