resource "garage_bucket" "this" {
  for_each     = var.buckets
  global_alias = each.value
}

resource "garage_key" "this" {
  name          = "main"
  never_expires = true
}

# just one key with access to all buckets, couldn't care less lol
resource "garage_bucket_permission" "this" {
  for_each      = var.buckets
  access_key_id = garage_access_key.this.id
  bucket_id     = garage_bucket.this[each.key].id
  read          = true
  write         = true
  depends_on    = [garage_bucket.this]
}
