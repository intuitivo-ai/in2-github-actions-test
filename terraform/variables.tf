variable "commit_id" {}
variable "environment" {}
variable "environment_variables" { default = {} }
variable "region" { default = "us-east-1" }
variable "staging_role" { default = "arn:aws:iam::596234539184:role/Cross-Account-Access-github" }
variable "vpc_id" {}
