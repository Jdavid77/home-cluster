locals {
  application_name_normalized = replace(trimspace(var.authentik_proxy_application_name), " ", "-")
}

resource "authentik_application" "name" {

  name              = local.application_name_normalized
  slug              = local.application_name_normalized
  protocol_provider = authentik_provider_proxy.proxy_provider.id
  group             = var.authentik_proxy_application_group
  meta_icon         = var.authentik_proxy_application_icon_url
  meta_description  = var.authentik_proxy_application_description

  depends_on = [
    authentik_provider_proxy.proxy_provider
  ]

}