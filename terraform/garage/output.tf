output "key_id" {
  value     = garage_key.this.id
  sensitive = true
}

output "key_secret" {
  value     = garage_key.this.secret_access_key
  sensitive = true
}
