data "cloudflare_record" "a_record" {
  zone_id  = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  hostname = var.cloudflare_domain_com
}

resource "cloudflare_record" "cname_record" {

  count = length(var.cloudflare_records)

  zone_id = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  name    = var.cloudflare_records[count.index]
  value   = var.cloudflare_domain_com
  type    = "CNAME"
  ttl     = 1
  proxied = true

}




