output "flux_access_id" {
  value = module.key["flux"].access_id
}

output "flux_access_key" {
  value     = module.key["flux"].access_key
  sensitive = true
}

output "omv_access_id" {
  value = module.key["omv"].access_id
}

output "omv_access_key" {
  value     = module.key["omv"].access_key
  sensitive = true
}
