resource "akeyless_auth_method_api_key" "this" {
  name = var.name
}

resource "akeyless_role" "this" {
  for_each = { for r in var.roles : r.name => r }

  name = "${var.name}-${each.value.name}"

  rules {
    capability = each.value.capabilities
    path       = each.value.path
    rule_type  = "item-rule"
  }

  # deny overrides any other capability on the same path, within this role
  dynamic "rules" {
    for_each = each.value.deny_paths
    content {
      capability = ["deny"]
      path       = rules.value
      rule_type  = "item-rule"
    }
  }
}

resource "akeyless_associate_role_auth_method" "this" {
  for_each = { for r in var.roles : r.name => r }

  am_name   = akeyless_auth_method_api_key.this.name
  role_name = akeyless_role.this[each.key].name
}
