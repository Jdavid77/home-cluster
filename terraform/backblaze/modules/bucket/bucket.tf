resource "b2_bucket" "this" {
  bucket_name = var.name
  bucket_type = "allPrivate"
  file_lock_configuration {
    is_file_lock_enabled = true
  }
}

resource "b2_application_key" "this" {
  key_name     = "${var.name}-bucket"
  capabilities = ["listFiles", "readFiles", "writeFiles"]
  bucket_id = b2_bucket.this.id
}
