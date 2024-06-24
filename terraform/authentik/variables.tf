variable "authentik_api_token" {
  type        = string
  description = "Authentik API Token"
}
variable "authentik_api_url" {
  type        = string
  description = "Authentik API URL"
}

variable "bind_password" {
  type        = string
  description = "LLDAP Bind Password"
}

variable "bind_cn" {
  type        = string
  description = "LLDAP Bind CN"
}
