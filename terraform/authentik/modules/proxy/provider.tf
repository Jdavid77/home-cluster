data "authentik_flow" "default-authorization-flow" {
  slug = "default-provider-authorization-implicit-consent"
}

resource "authentik_provider_proxy" "proxy_provider" {
  name               = var.authentik_proxy_application_name
  external_host      = var.authentik_proxy_external_host
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  mode               = "forward_single"

  depends_on = [
    data.authentik_flow.default-authorization-flow
  ]
}