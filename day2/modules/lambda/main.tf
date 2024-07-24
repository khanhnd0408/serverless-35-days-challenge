resource "aws_lambda_function" "lambda_function" {
  filename         = var.absolute_package_path
  function_name    = var.function_name
  role             = var.exec_lambda_role
  handler          = var.function_handler
  source_code_hash = var.package_hash
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size

  architectures = var.architectures

  layers = [aws_lambda_layer_version.this.arn]
  
  ephemeral_storage {
    size = var.storage_size
  }


  environment {
    variables = var.env_parameters
  }

  tags = var.tags
}

resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_lambda_layer_version" "this" {
  filename   = var.layer_zip_path
  layer_name = var.layer_name

  source_code_hash = try(filemd5(var.layer_zip_path), null)
  compatible_runtimes = [var.runtime]
}
