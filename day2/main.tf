locals {
  exec_lambda_policy_json = templatefile("${path.cwd}/templates/lambda_exec.json.tpl", {
    arns = [
      module.remove_background_function.function_arn,
      "${module.remove_background_function.function_arn}:*"
    ]
    }
  )


  access_bucket_policy_json = templatefile("${path.cwd}/templates/access_bucket.json.tpl", {
    bucket_name = module.image_bucket.bucket_name
  })
}

module "image_bucket" {
  source = "./modules/s3"

  bucket_name         = "${var.app_name}-${var.env_name}-images-bucket"
  lambda_function_arn = module.remove_background_function.function_arn

  python_lib_title = "lib.zip"
  python_lib_zip = "${local.archive_full_path}/lib.zip"

  upload_object_depend_on = null_resource.python_lib
}

module "remove_background_function" {
  source = "./modules/lambda"

  absolute_package_path = data.archive_file.lambda.output_path
  function_name         = "${var.app_name}-${var.env_name}-invoke-api-function"
  exec_lambda_role      = module.lambda_role.role_arn
  function_handler      = var.lambda_handler

  package_hash  = data.archive_file.lambda.output_base64sha256
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  architectures = var.lambda_architectures
  memory_size   = var.memory_size
  storage_size  = var.storage_size

  layer_zip_path = data.local_file.python_layer_zip.filename
  layer_name     = "${var.app_name}-${var.env_name}-lib"
  # requirement_path = ${local.function_path}/requirements_layer.txt
  bucket_arn     = module.image_bucket.bucket_arn
  layer_depends_on = [ data.local_file.python_layer_zip ]

  env_parameters = {
    API_URL = "https://api.ipify.org?format=json"
  }
}

module "lambda_exec_policy" {
  source = "./modules/policy"

  policy_name = "${var.app_name}-${var.env_name}-exec-lambda-policy"
  policy      = local.exec_lambda_policy_json
  policy_tags = {}
}

module "lambda_access_bucket_policy" {
  source = "./modules/policy"

  policy_name = "${var.app_name}-${var.env_name}-lambda-access-bucket-policy"
  policy      = local.access_bucket_policy_json
  policy_tags = {}
}

module "lambda_role" {
  source = "./modules/role"

  role_name            = "${var.app_name}-${var.env_name}-invoke-api-role"
  trusted_role_service = "lambda.amazonaws.com"
  attach_policies_arn  = [module.lambda_exec_policy.policy_arn, module.lambda_access_bucket_policy.policy_arn]
}
