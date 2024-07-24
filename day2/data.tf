locals {
  function_path = "${path.module}/functions/day2-function"
  archive_path  = "${path.module}/functions/archived"
  archive_full_path  = "${path.cwd}/functions/archived"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${local.function_path}/lambda_function.py"
  output_path = "${local.archive_path}/day2-function.zip"
}

resource "null_resource" "python_layer" {
  triggers = {
    requirements_hash = filemd5("${local.function_path}/requirements_layer.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${local.archive_path}/layer/python

      pip install -r ${local.function_path}/requirements_layer.txt -t ${local.archive_path}/layer/python

      cd ${local.archive_full_path}/layer
      zip -r ${local.archive_full_path}/layer.zip .

      rm -rf ${local.archive_full_path}/layer
    EOT
  }
}

data "local_file" "python_layer_zip" {
  filename = "${local.archive_full_path}/layer.zip"
  depends_on = [null_resource.python_layer]
}

resource "null_resource" "python_lib" {
  triggers = {
    requirements_hash = filemd5("${local.function_path}/requirements_lib.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${local.archive_path}/lib/python

      pip install -r ${local.function_path}/requirements_lib.txt -t ${local.archive_path}/lib/python

      cd ${local.archive_full_path}/lib
      zip -r ${local.archive_full_path}/lib.zip .

      rm -rf ${local.archive_full_path}/lib
    EOT
  }
}
