locals {
  proxy_ids = flatten([
    for p in module.proxy : p.proxy_provider_id
  ])
}

resource "authentik_outpost" "outpost" {
  name = "proxy"
  protocol_providers = local.proxy_ids

  depends_on = [ module.proxy ]
}