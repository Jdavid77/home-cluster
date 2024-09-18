resource "random_password" "random_client_secret" {
  length  = 128
  special = false
}

resource "random_id" "random_client_id" {
  byte_length = 40
}

resource "authentik_provider_oauth2" "oidc_provider" {
  name               = var.authentik_oidc_application_name
  client_id          = random_id.random_client_id.dec
  authorization_flow = data.authentik_flow.default-authorization-flow.id
  client_secret      = random_password.random_client_secret.result
  property_mappings  = data.authentik_property_mapping_provider_scope.property_mappings.ids
  signing_key        = data.authentik_certificate_key_pair.generated.id

  depends_on = [
    random_id.random_client_id,
    random_password.random_client_secret,
    data.authentik_certificate_key_pair.generated,
    data.authentik_property_mapping_provider_scope.property_mappings,
    data.authentik_flow.default-authorization-flow
  ]
}
