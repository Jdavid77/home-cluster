resource "akeyless_role" "this" {

  name = "ReadOnly"

  rules {
    capability = ["read", "list", "create"]
    path       = "/*"
    rule_type  = "item-rule"
  }

}
