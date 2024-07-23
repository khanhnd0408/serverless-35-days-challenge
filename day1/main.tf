locals {
  policy_json = templatefile("${path.cwd}/templates/lambda_exec.json.tpl", {
    arns = [
      module.invoke_api_function.function_arn,
      "${module.invoke_api_function.function_arn}:*"
    ]
    }
  )
}

module "invoke_api_function" {
  source = "./modules/lambda"

  absolute_package_path = data.archive_file.lambda.output_path
  function_name         = "${var.app_name}-${var.env_name}-invoke-api-function"
  exec_lambda_role      = module.lambda_role.role_arn
  function_handler      = var.lambda_handler

  package_hash  = data.archive_file.lambda.output_base64sha256
  runtime       = var.lambda_runtime
  timeout       = var.lambda_timeout
  architectures = var.lambda_architectures

  env_parameters = {
    API_URL = "https://api.ipify.org?format=json"
  }
}

module "lambda_exec_policy" {
  source = "./modules/policy"

  policy_name = "${var.app_name}-${var.env_name}-exec-lambda-policy"
  policy      = local.policy_json
  policy_tags = {}
}

module "lambda_role" {
  source = "./modules/role"

  role_name            = "${var.app_name}-${var.env_name}-invoke-api-role"
  trusted_role_service = "lambda.amazonaws.com"
  attach_policies_arn  = [module.lambda_exec_policy.policy_arn]
}
