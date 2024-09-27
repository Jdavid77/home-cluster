resource "minio_s3_bucket" "this" {
  bucket = var.name
  acl    = "private"
}
