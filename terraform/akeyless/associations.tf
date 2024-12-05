resource "akeyless_associate_role_auth_method" "ro" {
  am_name   = akeyless_auth_method_api_key.this.name
  role_name = akeyless_role.ro.name
}

resource "akeyless_associate_role_auth_method" "cm-w" {
  am_name   = akeyless_auth_method_api_key.this.name
  role_name = akeyless_role.cm-w.name
}
