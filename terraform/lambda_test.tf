resource "aws_lambda_function" "lambda-test" {
  function_name = "${var.environment}-lambda-test"
  package_type  = "Zip"
  role          = aws_iam_role.lambda-test.arn
  s3_bucket     = aws_s3_bucket.bucket.id
  s3_key        = aws_s3_bucket_object.lambda-test.key

  handler = "lambda_function.lambda_handler"
  runtime = "python3.9"

  layers = [
    #    "arn:aws:lambda:us-east-1:706851696280:layer:opencv-python_3_7:1"
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

resource "aws_s3_bucket_object" "lambda-test" {
  bucket = aws_s3_bucket.bucket.id
  key    = "lambda-test/${var.environment}/lambda-test.zip"
  source = "lambda.zip"

  source_hash = sha1("lambda.zip")
}
