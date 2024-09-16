resource "akeyless_role" "read_only" {

  name = "ReadOnly"

  rules {
    capability = ["read", "list"]
    path       = "/*"
    rule_type  = "item-rule"
  }

}
