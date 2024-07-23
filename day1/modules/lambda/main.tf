resource "aws_lambda_function" "lambda_function" {
  filename         = var.absolute_package_path
  function_name    = var.function_name
  role             = var.exec_lambda_role
  handler          = var.function_handler
  source_code_hash = var.package_hash
  runtime          = var.runtime
  timeout          = var.timeout

  architectures = var.architectures

  environment {
    variables = var.env_parameters
  }

  tags = var.tags
}

resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowInvokeFromNoWhere"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "*"
}
