output "key_id" {
  value = garage_access_key.this.access_key_id
}

output "key_secret" {
  value     = garage_access_key.this.secret_access_key
  sensitive = true
}
