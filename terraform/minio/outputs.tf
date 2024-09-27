output "app_credentials" {
  value = {
    for app in local.apps : app => {
      access_key = module.app[app].access_key
      secret_key = module.app[app].secret_key
    }
  }
  sensitive = true
}
