#Create a local kubernetes connection

resource "authentik_outpost" "outpost" {
  name = "authentik-home-outpost"
  protocol_providers = var.authentik_proxy_provider_ids
}
