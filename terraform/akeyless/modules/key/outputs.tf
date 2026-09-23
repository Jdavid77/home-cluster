output "access_id" {
  value = akeyless_auth_method_api_key.this.access_id
}

output "access_key" {
  value     = akeyless_auth_method_api_key.this.access_key
  sensitive = true
}
