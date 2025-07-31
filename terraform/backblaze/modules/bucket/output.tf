output "access_key" {
  value = b2_application_key.this.application_key_id
  sensitive = true
}

output "secret_key" {
  value = b2_application_key.this.application_key
  sensitive = true
}
