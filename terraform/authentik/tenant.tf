resource "authentik_tenant" "home-cluster" {
  domain              = "authentik.${var.external_host}"
  default             = true
  branding_title      = "Home-Cluster"
  branding_favicon    = "https://icons8.com/icon/91350/lock"
  branding_logo       = "https://i.postimg.cc/JzSPht3L/logo-3.png"
  flow_authentication = data.authentik_flow.default-authentication-flow.id
  flow_invalidation   = data.authentik_flow.default-invalidation-flow.id
  flow_user_settings  = data.authentik_flow.default-user-settings-flow.id
}