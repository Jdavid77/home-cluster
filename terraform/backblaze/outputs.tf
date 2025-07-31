output "bucket_credentials" {
  value = {
    for bucket in local.buckets : bucket => {
      access_key = module.bucket[bucket].access_key
      secret_key = module.bucket[bucket].secret_key
    }
  }
  sensitive = true
}
