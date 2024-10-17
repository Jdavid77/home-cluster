resource "akeyless_role" "this" {

  name = "ReadOnly"

  rules {
    capability = ["read", "list"]
    path       = "/*"
    rule_type  = "item-rule"
  }

}
