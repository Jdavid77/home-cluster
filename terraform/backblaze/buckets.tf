locals {
  buckets = [
    # names must be globally unique....
    "jnobrega-postgres-backup",
    "jnobrega-obsidian"
  ]
}

module "bucket" {
  source = "./modules/bucket"
  for_each = toset(local.buckets)
  name = each.value

  providers = {
    b2 = b2
  }
}
