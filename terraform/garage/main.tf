resource "garage_bucket" "this" {
  for_each = var.buckets
  name     = each.value
}

resource "garage_access_key" "this" {
  name          = "volsync"
  never_expires = true
}

# just one key with access to all buckets, couldn't care less lol
resource "garage_permission" "this" {
  for_each      = var.buckets
  access_key_id = garage_access_key.this.id
  bucket_id     = each.value
  read          = true
  write         = true
  owner         = true
  depends_on    = [garage_bucket.this]
}
