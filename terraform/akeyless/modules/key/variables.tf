variable "name" {
  type        = string
  description = "Akeyless auth method name."
}

variable "roles" {
  type = list(object({
    name         = string
    path         = string
    capabilities = list(string)
  }))
  default     = []
  description = "Roles to create and associate with this key."
}
