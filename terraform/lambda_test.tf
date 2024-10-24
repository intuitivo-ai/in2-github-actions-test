module "alb" {
  providers = {
    aws.US = aws.US
  }
  source      = "git@github.com:intuitivo-ai/in2-terraform-module-alb?ref=test_cdn"
  name = "alb-test"
  environment = var.environment
  region      = var.region
  service_port = "3000"
  cdn = true
}
module "transactions" {
  source      = "git@github.com:intuitivo-ai/in2-terraform-module-s3.git"
  bucket_name = "in2-test"
  cdn         = true
  environment = var.environment
  region      = var.region

  cors_allowed_methods = ["GET"]
  cors_allowed_origins = ["*"]
}
