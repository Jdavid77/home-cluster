resource "akeyless_associate_role_auth_method" "flux-ro" {
  am_name   = akeyless_auth_method_api_key.flux_key.name
  role_name = akeyless_role.read_only.name

  depends_on = [akeyless_auth_method_api_key.flux_key, akeyless_role.read_only]
}