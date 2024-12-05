resource "akeyless_role" "ro" {

  name = "ReadOnly"

  rules {
    capability = ["read", "list"]
    path       = "/*"
    rule_type  = "item-rule"
  }

}

resource "akeyless_role" "cm-w" {

  name = "CM-Read-Write"

  rules {
    capability = ["create","update","read","delete","list"]
    path       = "/cert-manager/*"
    rule_type  = "item-rule"
  }

}
