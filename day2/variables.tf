variable "app_name" {
  type    = string
  default = "dummy"
}

variable "env_name" {
  type    = string
  default = "test"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.12"
}

variable "lambda_handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "lambda_architectures" {
  type    = list(string)
  default = ["arm64"]
}

variable "lambda_timeout" {
  type    = number
  default = 120
}

variable "storage_size" {
  type = number
  default = 2048
}

variable "memory_size" {
  type    = number
  default = 2048
}
