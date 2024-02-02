provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.staging_role
  }
  default_tags {
    tags = {
    Squad = "Infra"
    Environment = var.environment
    Repository = "in2-github-actions-test"
  } }
}

{% comment %} provider "aws" {
  alias  = "US"
  region = "us-east-1"
  assume_role { 
    role_arn = var.assume_role
  }
  default_tags { 
    tags = {
    Squad = "Infra"
    Environment = var.environment
    Repository = "in2-github-actions-test"
  } }
} {% endcomment %}

terraform {
  backend "s3" {
    bucket = "in2-terraform-cross"
    region = "us-east-2"
  }
}

data "aws_caller_identity" "aws" {}
