variable "bucket_name" {
  type        = string
}

variable "lambda_function_arn" {
  type        = string
}

variable "upload_object_depend_on" {
  type = any
  default = null
}

variable "python_lib_title" {
  type = string
  default = ""
}

variable "python_lib_zip" {
  type = string
  default = ""
}

variable "tags" {
  type = map
  default = {}
}
