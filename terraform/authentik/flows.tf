data "authentik_flow" "default-authentication-flow" {
  slug = "default-authentication-flow"
}

data "authentik_flow" "default-invalidation-flow" {
  slug = "default-invalidation-flow"
}

data "authentik_flow" "default-user-settings-flow" {
  slug = "default-user-settings-flow"
}