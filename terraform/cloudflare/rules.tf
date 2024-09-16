resource "cloudflare_filter" "notportugal" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Block Requests that dont come from Portugal"
  expression  = "(ip.geoip.country ne \"PT\")"
}

resource "cloudflare_firewall_rule" "notportugal" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Block Requests that don't come from Portugal"
  filter_id   = cloudflare_filter.notportugal.id
  action      = "block"
}

resource "cloudflare_filter" "blockbots" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Block Known Bots"
  expression  = "(cf.client.bot)"
}

resource "cloudflare_firewall_rule" "blockbots" {
  zone_id     = lookup(data.cloudflare_zones.domain_com.zones[0], "id")
  description = "Block Known Bots"
  filter_id   = cloudflare_filter.blockbots.id
  action      = "block"
}
