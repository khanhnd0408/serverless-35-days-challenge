variable "absolute_package_path" {
  type = string
  default = ""
}

variable "ecr_image_uri" {
  type = string
  default = ""
}

variable "function_name" {
  type = string
}

variable "exec_lambda_role" {
  type = string
}

variable "function_handler" {
  type = string
}

variable "package_hash" {
  type = string
  default = ""
}

variable "runtime" {
  type = string
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "storage_size" {
  type    = number
  default = 512
}

variable "timeout" {
  type    = number
  default = 3
}

variable "env_parameters" {
  type    = map(any)
  default = {}
}

variable "architectures" {
  type    = list(string)
  default = ["x86_64"]
}

variable "layer_details" {
  type = list(object({
    layer_name = string
    zip_path   = string
  }))
  default = []
}

variable "tags" {
  type    = map(any)
  default = {}
}

variable "bucket_arn" {
  type = string
}

# variable "function_depends_on" {
#   type = any
# }
