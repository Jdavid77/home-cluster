terraform {
  backend "s3" {
    bucket = "jnobrega-tf-state"
    key    = "garage.tfstate"
    region = "auto"
    endpoints = {
      s3 = "https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
