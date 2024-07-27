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

  access_registry_policy_json = templatefile("${path.cwd}/templates/lambda_access_registry.json.tpl", {
    account_id      = data.aws_caller_identity.current.account_id,
    region          = data.aws_region.current.name,
    repository_name = var.repository_name
  })

  ecr_policy_json = templatefile("${path.cwd}/templates/ecr.json.tpl", {
    account_id = data.aws_caller_identity.current.account_id
  })
}

module "image_bucket" {
  source = "./modules/s3"

  bucket_name         = "${var.app_name}-${var.env_name}-images-bucket"
  lambda_function_arn = module.remove_background_function.function_arn

  # python_lib_title = "lib.zip"
  # python_lib_zip   = "${local.archive_full_path}/lib.zip"

  #  upload_object_depend_on = null_resource.python_lib
}

module "private_registry" {
  source = "./modules/ecr"

  repository_name = var.repository_name
  policy          = local.ecr_policy_json
}

module "remove_background_function" {
  source = "./modules/lambda"

  function_name    = "${var.app_name}-${var.env_name}-invoke-api-function"
  exec_lambda_role = module.lambda_role.role_arn
  function_handler = var.lambda_handler
  ecr_image_uri    = "${module.private_registry.repository_url}:${local.source_hash}"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  architectures    = var.lambda_architectures
  memory_size      = var.memory_size
  storage_size     = var.storage_size

  bucket_arn = module.image_bucket.bucket_arn

  env_parameters = {
    NUMBA_DISABLE_JIT = "1"
  }

  depends_on = [ null_resource.lambda_packaging ]
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

module "lambda_access_registry_policy" {
  source = "./modules/policy"

  policy_name = "${var.app_name}-${var.env_name}-lambda-access-registry-policy"
  policy      = local.access_registry_policy_json
  policy_tags = {}
}

module "lambda_role" {
  source = "./modules/role"

  role_name            = "${var.app_name}-${var.env_name}-invoke-api-role"
  trusted_role_service = "lambda.amazonaws.com"
  attach_policies_arn = [
    module.lambda_exec_policy.policy_arn,
    module.lambda_access_bucket_policy.policy_arn,
    module.lambda_access_registry_policy.policy_arn
  ]
}
