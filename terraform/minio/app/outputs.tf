output "access_key" {
  value = minio_iam_service_account.this.access_key
  sensitive = true
}

output "secret_key" {
  value = minio_iam_service_account.this.secret_key
  sensitive = true
}
