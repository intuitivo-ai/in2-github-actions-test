provider "aws" {
  region = "${var.region}"
  assume_role {
    role_arn     = null
    session_name = "GH-Actions"
  }
  default_tags {
    tags = {
      Environment = var.environment
      Repository  = "in2-github-actions-test"
      Squad       = "Infra"
    }
  }
}

provider "aws" {
  alias  = "US"
  region = "us-east-1"
  assume_role {
    role_arn     = null
    session_name = "GH-Actions"
  }
  default_tags {
    tags = {
      Environment = var.environment
      Repository  = "in2-github-actions-test"
      Squad       = "Infra"
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