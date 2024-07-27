locals {
  function_path     = "${path.module}/functions/day2-function"
  archive_path      = "${path.module}/functions/archived"
  archive_full_path = "${path.cwd}/functions/archived"
  docker_file_hash  = filemd5("${local.function_path}/Dockerfile")
  requirements_hash = filemd5("${local.function_path}/requirements.txt")
  function_hash     = filemd5("${local.function_path}/lambda_function.py")
  source_hash       = sha256(join(",", [local.docker_file_hash, local.function_hash, local.requirements_hash]))
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${local.function_path}/lambda_function.py"
  output_path = "${local.archive_path}/day2-function.zip"
}

resource "null_resource" "lambda_packaging" {
  triggers = {
    source_hash = local.source_hash
  }

  provisioner "local-exec" {
    command = <<EOT
      REGION="us-east-1"
      REPOSITORY_NAME="custom-lambda"
      ACCOUNT_ID=${data.aws_caller_identity.current.account_id}
      IMAGE_TAG="${local.source_hash}"
      
      CODE_DIRECTORY="./functions/day2-function"

      aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

      if [ $? -ne 0 ]; then
        echo "Failed to login to ECR"
        exit 1
      fi

      aws ecr describe-repositories --repository-names $REPOSITORY_NAME --region $REGION || aws ecr create-repository --repository-name $REPOSITORY_NAME --region $REGION

      docker build -t $REPOSITORY_NAME:$IMAGE_TAG -f $CODE_DIRECTORY/Dockerfile $CODE_DIRECTORY

      docker tag $REPOSITORY_NAME:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG

      docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPOSITORY_NAME:$IMAGE_TAG

      if [ $? -eq 0 ]; then
        echo "Image successfully pushed to ECR"
      else
        echo "Failed to push the image to ECR"
        exit 1
      fi
    EOT
  }
}

# resource "null_resource" "python_layer" {
#   triggers = {
#     requirements_hash = filemd5("${local.function_path}/requirements_layer.txt")
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       mkdir -p ${local.archive_path}/layer/python

#       pip install -r ${local.function_path}/requirements_layer.txt -t ${local.archive_path}/layer/python

#       cd ${local.archive_full_path}/layer
#       zip -r ${local.archive_full_path}/layer.zip .

#       rm -rf ${local.archive_full_path}/layer
#     EOT
#   }
# }

# data "local_file" "python_layer_zip" {
#   filename = "${local.archive_full_path}/layer.zip"
#   depends_on = [null_resource.python_layer]
# }

# resource "null_resource" "python_lib" {
#   triggers = {
#     requirements_hash = filemd5("${local.function_path}/requirements_lib.txt")
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       mkdir -p ${local.archive_path}/lib/python

#       pip install -r ${local.function_path}/requirements_lib.txt -t ${local.archive_path}/lib/python

#       cd ${local.archive_full_path}/lib
#       zip -r ${local.archive_full_path}/lib.zip .

#       rm -rf ${local.archive_full_path}/lib
#     EOT
#   }
# }
