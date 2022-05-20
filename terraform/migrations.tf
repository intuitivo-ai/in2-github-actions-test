resource "null_resource" "migrations" {

  triggers = {
    always_run = tostring(timestamp())
  }

  provisioner "local-exec" {
    command = <<EOF
aws ecs run-task --cluster staging-ecs-cluster --task-definition arn:aws:ecs:us-east-1:596234539184:task-definition/staging-in2-github-actions-test --network-configuration 'awsvpcConfiguration={subnets=[subnet-019d011dd4ce7c3fb,subnet-07344197e44994712,subnet-082ef283d63388eac],securityGroups=[sg-06bf958568fccd5bc],assignPublicIp=DISABLED}'
EOF
  }
}
