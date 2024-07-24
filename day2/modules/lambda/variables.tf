variable "absolute_package_path" {
  type = string
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
}

variable "runtime" {
  type = string
}

variable "memory_size" {
  type = number
  default = 128
}

variable "storage_size" {
  type = number
  default = 512
}

variable "timeout" {
  type    = number
  default = 3
}

variable "env_parameters" {
  type    = map
  default = {}
}

variable "architectures" {
  type    = list(string)
  default = ["x86_64"]
}

variable "layer_zip_path" {
  type = string
}

variable "layer_name" {
  type = string
}

variable "tags" {
  type    = map
  default = {}
}

variable "bucket_arn" {
  type = string
}

variable "layer_depends_on" {
  type = any
}
