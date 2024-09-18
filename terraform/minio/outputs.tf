output "longhorn_user" {
  value = minio_iam_service_account.longhorn_service_account.access_key
}

output "longhorn_password" {
  value     = minio_iam_service_account.longhorn_service_account.secret_key
  sensitive = true
}
