output "flux_access_id" {
  value     = akeyless_auth_method_api_key.this.access_id
}

output "flux_access_key" {
  value     = akeyless_auth_method_api_key.this.access_key
  sensitive = true
}

output "omv_access_id" {
  value     = akeyless_auth_method_api_key.omv.access_id
}

output "omv_access_key" {
  value     = akeyless_auth_method_api_key.omv.access_key
  sensitive = true
}
