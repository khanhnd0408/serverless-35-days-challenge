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

variable "tags" {
  type    = map
  default = {}
} 
