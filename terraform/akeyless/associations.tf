resource "akeyless_associate_role_auth_method" "this" {
  am_name   = akeyless_auth_method_api_key.this.name
  role_name = akeyless_role.this.name

}
