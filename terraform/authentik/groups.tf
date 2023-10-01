resource "authentik_user" "jnobrega_user" {
  username = "jnobrega"
  name     = "jnobrega"
  email    = var.login_email
}

resource "authentik_group" "grafana_admin" {
  name         = "Grafana Admins"
  users        = [authentik_user.jnobrega_user.id]
  is_superuser = false
}

resource "authentik_group" "authentik_admin" {
  name         = "Authentik Admin"
  users        = [authentik_user.jnobrega_user.id]
  is_superuser = true
}

