resource "null_resource" "sleep" {
  triggers = {
    always_run = tostring(timestamp())
  }
  provisioner "local-exec" {
    command = "sleep 300"
  }
}
