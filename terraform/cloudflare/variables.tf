variable "cloudflare_email" {
  type        = string
  description = "Cloudflare Email Address"
}

variable "cloudflare_account_id" {
  type = string
  description = "Cloudflare Account ID"
}

variable "cloudflare_api_key" {
  type        = string
  description = "Cloudflare API Key"
}

variable "cloudflare_api_token" {
  type        = string
  description = "Cloudflare API Token"
}

variable "cloudflare_domain_com" {
  type        = string
  description = "My .com domain"
}

variable "cloudflare_records" {
  type = list(string)
  description = "CNAME Records"
} 

variable "cloudflare_buckets" {
  type = list(string)
  description = "R2 Buckets"
} 