output "flux_access_id" {
  value     = akeyless_auth_method_api_key.this.access_id
  sensitive = true
}

output "flux_access_key" {
  value     = akeyless_auth_method_api_key.this.access_key
  sensitive = true
}
