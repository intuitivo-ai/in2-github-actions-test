#module "test" {
#  source = "git@github.com:intuitivo-ai/in2-terraform-module-ecr"
#  name   = "test123"
#}
/*
module "database" {
  source      = "git@github.com:intuitivo-ai/in2-terraform-module-db-aurora"
  environment = var.environment
  region      = var.region
  vpc_id      = var.vpc_id

  name          = "test"
  database_name = "test"
}

output "db_credentials" {
  sensitive = true
  value     = module.database.master_credentials
}

output "db_endpoint" {
  value = module.database.endpoint
}
*/
