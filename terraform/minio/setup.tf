locals {
  apps = [
    "longhorn",
    "loki",
    "velero",
    "postgres",
    "obsidian",
    "restic"
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
