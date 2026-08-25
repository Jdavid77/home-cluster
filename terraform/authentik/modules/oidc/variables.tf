variable "authentik_oidc_application_name" {
  type        = string
  description = "Authentik OIDC Application Name"
}

variable "authentik_oidc_application_icon_url" {
  type        = string
  description = "Authentik OIDC Icon URL"
}
variable "authentik_oidc_application_group" {
  type        = string
  description = "Application Group"
  default     = "OIDC"
}
variable "authentik_oidc_application_description" {
  type        = string
  description = "Application Description"
  default     = "This is an OIDC Provider for the application"
}

variable "authentik_oidc_client_type" {
  type        = string
  description = "OIDC client type: 'confidential' or 'public'"
  default     = "confidential"

  validation {
    condition     = contains(["confidential", "public"], var.authentik_oidc_client_type)
    error_message = "client_type must be 'confidential' or 'public'."
  }
}

variable "authentik_oidc_sub_mode" {
  type        = string
  description = "Subject mode for the OIDC provider"
  default     = "hashed_user_id"

  validation {
    condition     = contains(["hashed_user_id", "user_id", "user_uuid", "user_username", "user_email", "user_upn"], var.authentik_oidc_sub_mode)
    error_message = "sub_mode must be one of: hashed_user_id, user_id, user_uuid, user_username, user_email, user_upn."
  }
}

variable "authentik_oidc_redirect_uris" {
  type = list(object({
    matching_mode     = optional(string, "strict")
    redirect_uri_type = optional(string, "authorization")
    url               = string
  }))
  description = "List of allowed redirect URIs for the OIDC provider"
  default     = []
}
