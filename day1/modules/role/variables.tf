variable "role_name" {
  type = string
}

variable "role_tags" {
  default = {}
}

variable "trusted_role_service" {
  type = string
}

variable "attach_policies_arn" {
  type = list(string)
}
