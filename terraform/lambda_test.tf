
module "transactions" {
  source      = "git@github.com:intuitivo-ai/in2-terraform-module-s3.git"
  bucket_name = "in2-test"
  cdn         = true
  environment = var.environment
  region      = var.region

  cors_allowed_methods = ["GET"]
  cors_allowed_origins = ["*"]
}
