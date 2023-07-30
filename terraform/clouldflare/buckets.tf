resource "cloudflare_r2_bucket" "bucket" {

  count = length(var.cloudflare_buckets) 

  account_id = var.cloudflare_account_id
  name       = var.cloudflare_buckets[count.index]

}