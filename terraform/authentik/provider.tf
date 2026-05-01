provider "authentik" {
  url   = local.authentik_api_url
  token = local.authentik_api_token
}
