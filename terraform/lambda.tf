resource "aws_lambda_function" "email-handler" {
  function_name = "emailHandler"
  role          = "arn:aws:iam::833738481970:role/service-role/SESforLambda"

  s3_bucket   = "centeredge-techfiles"
  s3_key      = "lambda/emailHandler.zip"
  handler     = "index.handler"
  runtime     = "nodejs20.x"
  memory_size = 128
  timeout     = 3
  ephemeral_storage {
    size = 512
  }

  environment {
    variables = {
      "bucketName" = "centeredge-ops-emails"
      "dbTtlDays"  = "90"
    }
  }
}
