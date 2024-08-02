provider "aws" {
  region = var.region
  assume_role {
    role_arn     = var.assume_role
    session_name = "GH-Actions"
  }
  default_tags {
    tags = {
      Squad       = "Infra"
      Environment = var.environment
      Repository  = "in2-github-actions-test"
    }
  }
}

provider "aws" {
  alias  = "US"
  region = "us-east-1"
  assume_role {
    role_arn     = var.assume_role
    session_name = "GH-Actions"
  }
  default_tags {
    tags = {
      Squad       = "Infra"
      Environment = var.environment
      Repository  = "in2-github-actions-test"
   }
  }
 }

terraform {
  backend "s3" {
    bucket = "in2-terraform-in2-github-actions-test"
    region = "us-east-1"
  }
}

data "aws_caller_identity" "aws" {}

