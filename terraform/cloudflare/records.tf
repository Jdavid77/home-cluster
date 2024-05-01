data "cloudflare_record" "a_record" {
  zone_id  = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  hostname = var.cloudflare_domain_com
}






