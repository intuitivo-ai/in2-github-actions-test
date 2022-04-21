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
  bucket = substr("in2-test-${var.commit_id}", 0, 32)
}

#resource "null_resource" "sleep60" {
#  provisioner "local-exec" {
#    command = "sleep 60"
#  }
#}
