data "aws_lambda_layer_version" "layer" {
  layer_name         = "slack_sdk_3_7"
  compatible_runtime = "python3.7"
}

resource "aws_lambda_function" "lambda-test" {
  function_name = "${var.environment}-lambda-test"
  package_type  = "Zip"
  role          = aws_iam_role.lambda-test.arn
  s3_bucket     = aws_s3_bucket.bucket.id
  s3_key        = aws_s3_object.lambda-test.key

  source_code_hash = filebase64sha256("../lambda.zip")

  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"

  layers = [
    data.aws_lambda_layer_version.layer.arn,
  ]
}

resource "aws_iam_role" "lambda-test" {
  name = "${var.environment}-lambda-test"
  path = "/service-role/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole", Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  managed_policy_arns = []
}

resource "aws_s3_object" "lambda-test" {
  bucket      = aws_s3_bucket.bucket.id
  key         = "lambda-test/${var.environment}/lambda-test.zip"
  source      = "../lambda.zip"
  source_hash = filebase64sha256("../lambda.zip")
}
