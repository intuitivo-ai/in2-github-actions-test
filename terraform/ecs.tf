module "ecs" {
  source      = "git@github.com:intuitivo-ai/in2-terraform-module-ecs"
  name        = "in2-github-actions-test"
  port        = 80
  commit_id   = var.commit_id
  env_vars    = var.environment_variables
  environment = var.environment
  region      = var.region
  vpc_id      = var.vpc_id
}
