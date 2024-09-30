locals {
  apps = [
    "longhorn",
    "loki"
  ]
}

module "app" {
  source = "./app"
  for_each = toset(local.apps)
  name = each.value

  providers = {
    minio = minio
  }
}
