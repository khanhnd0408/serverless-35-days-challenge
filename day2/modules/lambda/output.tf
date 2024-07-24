output "function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "function_invoke_arn" {
  value = aws_lambda_function.lambda_function.invoke_arn
}
