variable "region" { default = "us-east-2" }

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "in2-terraform-cross"
    key    = "in2-terraform-in2-github-actions-test/test.tfstate"
    region = "us-east-2"
  }
}

# Create bucket temp
resource "aws_s3_bucket" "bucket" {
  bucket = "in2-terraform-in2-github-actions-test-TEMP"
}
