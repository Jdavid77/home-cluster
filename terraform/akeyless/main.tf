locals {
  keys = {
    flux = {
      name = "Flux-Key"
      roles = [
        { name = "ReadOnly", path = "/*", capabilities = ["read", "list"] },
        { name = "CM-Read-Write", path = "/cert-manager/*", capabilities = ["create", "update", "read", "delete", "list"] },
      ]
    }
    omv = {
      name = "OMV"
      roles = [
        { name = "CM-Read-Write", path = "/cert-manager/*", capabilities = ["create", "update", "read", "delete", "list"] },
      ]
    }
  }
}

module "key" {
  source   = "./modules/key"
  for_each = local.keys

  name  = each.value.name
  roles = each.value.roles
}
