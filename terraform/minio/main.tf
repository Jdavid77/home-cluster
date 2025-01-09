terraform {

  backend "s3" {
    bucket = "minio"
    key    = "minio.tfstate"
    region = "weur"
    endpoints = {
      s3 = "https://015ce648cc705f6d069fe6068434a576.r2.cloudflarestorage.com/minio"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.2.2"
    }
  }

}
