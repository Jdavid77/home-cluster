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
    # akeyless-mcp: item names only, never values. It may delete unused items,
    # but never under /cert-manager/, which OMV uses outside the cluster.
    mcp = {
      name = "MCP"
      roles = [
        { name = "List", path = "/*", capabilities = ["list", "delete"], deny_paths = ["/cert-manager/*"] },
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
