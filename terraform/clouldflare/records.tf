data "cloudflare_record" "a_record" {
  zone_id  = var.cloudflare_zone_id
  hostname = var.cloudflare_domain_com
}

resource "cloudflare_record" "cname_record" {

  count = length(var.cloudflare_records)

  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_records[count.index]
  value   = var.cloudflare_domain_com
  type    = "CNAME"
  ttl     = 1
  proxied = true

}




