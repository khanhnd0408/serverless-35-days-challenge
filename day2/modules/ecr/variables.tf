variable "repository_name" {
  type = string
}

variable "policy" {
  type = any
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
