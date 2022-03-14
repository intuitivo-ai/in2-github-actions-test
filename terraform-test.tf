variable "commit_id" {}
variable "region" { default = "us-east-2" }
variable "staging_role" { default = "arn:aws:iam::596234539184:role/Cross-Account-Access-github" }

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.staging_role
  }
}

terraform {
  backend "s3" {
    bucket = "in2-terraform-cross"
    region = "us-east-2"
  }
}

# Create bucket temp
resource "aws_s3_bucket" "bucket" {
  bucket = "in2-terraform-in2-github-actions-test-${var.commit_id}"
}
