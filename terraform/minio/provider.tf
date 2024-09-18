provider "minio" {
  minio_server   = var.minio_server
  minio_region   = "weur"
  minio_user     = var.minio_user
  minio_password = var.minio_password
}
