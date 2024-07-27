locals {
  deploy_type = var.absolute_package_path == "" ? "Image":"Zip"
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = var.function_name
  role             = var.exec_lambda_role
  handler          = local.deploy_type == "Zip" ? var.function_handler:null
  filename         = local.deploy_type == "Zip" ? var.absolute_package_path:null
  source_code_hash = local.deploy_type == "Zip" ? var.package_hash:null
  image_uri        = var.ecr_image_uri
  runtime          = local.deploy_type == "Zip" ? var.runtime:null
  timeout          = var.timeout
  memory_size      = var.memory_size
  package_type     = local.deploy_type

  architectures = var.architectures

  layers = local.deploy_type == "Zip" ? try(flatten([for obj in var.layer_details: [
    aws_lambda_layer_version.this[obj.layer_name].arn
  ]]), []) : null
  
  ephemeral_storage {
    size = var.storage_size
  }


  environment {
    variables = var.env_parameters
  }

  tags = var.tags

  # depends_on = [var.function_depends_on]
}

resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_lambda_layer_version" "this" {
  for_each   = { for obj in var.layer_details : obj.layer_name => obj}
  filename   = each.value.layer_name
  layer_name = each.value.zip_path

  source_code_hash = try(filemd5(each.value.zip_path), "")
  compatible_runtimes = [var.runtime]
}
