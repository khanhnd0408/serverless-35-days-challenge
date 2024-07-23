data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/functions/day1-function/lambda_function.py"
  output_path = "${path.module}/functions/archived/day1-function.zip"
}
