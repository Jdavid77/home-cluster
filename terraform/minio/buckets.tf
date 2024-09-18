resource "minio_s3_bucket" "longhorn_backups" {
  bucket = "longhorn-backups"
  acl    = "private"
}
